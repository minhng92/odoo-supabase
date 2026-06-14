#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

# Remove all files and folders except itself, .gitignore, and the "screenshots" folder
for item in * .[!.]* ..?*; do
    if [ "$item" = "$SCRIPT_NAME" ] || [ "$item" = ".gitignore" ] || [ "$item" = "screenshots" ] || [ "$item" = ".git" ] || [ "$item" = "LICENSE" ] || [ "$item" = "README.MD" ]; then
        continue
    fi
    if [ -e "$item" ] || [ -L "$item" ]; then
        if ! rm -rf "$item"; then
            echo "Skip: cannot delete $item"
            continue
        fi
    fi
done

# Shallow clone repositories and remove their .git folders
git clone --depth 1 git@github.com:minhng92/supabase-docker-compose.git supabase-docker-compose
rm -rf supabase-docker-compose/.git

git clone --depth 1 git@github.com:minhng92/odoo-19-docker-compose.git odoo-19-docker-compose
rm -rf odoo-19-docker-compose/.git

# Append Odoo database user to supabase roles
cat >> supabase-docker-compose/volumes/db/roles.sql << 'EOF'
CREATE USER odoo SUPERUSER CREATEDB CREATEROLE REPLICATION;
ALTER USER odoo WITH PASSWORD :'pgpass';
EOF

# Update default database name in supabase .env
sed -i 's/POSTGRES_DB=postgres/POSTGRES_DB=odooxsupabase/g' supabase-docker-compose/.env



# Modify odoo entrypoint to install base module on startup
python3 << 'PYEOF'
with open('odoo-19-docker-compose/entrypoint.sh', 'r') as f:
    content = f.read()

content = content.replace(
    'exec odoo "$@" "${DB_ARGS[@]}"',
    'exec odoo "$@" "${DB_ARGS[@]}" "-i base"'
)

with open('odoo-19-docker-compose/entrypoint.sh', 'w') as f:
    f.write(content)
PYEOF

# Modify odoo run.sh to add KONG_PORT parameter and Supabase integration
python3 << 'PYEOF'
with open('odoo-19-docker-compose/run.sh', 'r') as f:
    content = f.read()

# Add KONG_PORT variable declaration
content = content.replace('CHAT=""', 'CHAT=""\nKONG_PORT="8000"')

# Add --kong-port case before --password
content = content.replace(
    '    --password)',
    '    --kong-port)\n      KONG_PORT="$2"\n      shift 2\n      ;;\n    --password)'
)

# Update usage strings to include --kong-port
content = content.replace(
    '--chat <chat_port> [--password',
    '--chat <chat_port> [--kong-port <kong_port>] [--password'
)

# # Update validation to require KONG_PORT
# if '|| [[ -z "$KONG_PORT" ]]' not in content:
#     content = content.replace(
#         '|| [[ -z "$CHAT" ]]',
#         '|| [[ -z "$CHAT" ]] || [[ -z "$KONG_PORT" ]]'
#     )

# Insert macOS sed line for KONG_HTTP_PORT in .env after CHAT sed line
content = content.replace(
    "  sed -i '' 's/20019/'$CHAT'/g' $DESTINATION/docker-compose.yml",
    "  sed -i '' 's/20019/'$CHAT'/g' $DESTINATION/docker-compose.yml\n  sed -i '' 's/KONG_HTTP_PORT=8000/KONG_HTTP_PORT='$KONG_PORT '/g' $DESTINATION/.env"
)

# Insert Linux sed line for KONG_HTTP_PORT in .env after CHAT sed line
content = content.replace(
    "  sed -i 's/20019/'$CHAT'/g' $DESTINATION/docker-compose.yml",
    "  sed -i 's/20019/'$CHAT'/g' $DESTINATION/docker-compose.yml\n  sed -i 's/KONG_HTTP_PORT=8000/KONG_HTTP_PORT='$KONG_PORT '/g' $DESTINATION/.env"
)

# Append Supabase Studio echo line at the end
supabase_line = 'echo "Supabase Studio started at http://localhost:$KONG_PORT | Dashboard User: supabase | Dashboard Password: minhng.info"'
if supabase_line not in content:
    content = content.rstrip() + '\n' + supabase_line + '\n'

# Replace clone URL to odoo-supabase
content = content.replace(
    'https://github.com/minhng92/odoo-19-docker-compose',
    'https://github.com/minhng92/odoo-supabase'
)

with open('odoo-19-docker-compose/run.sh', 'w') as f:
    f.write(content)
PYEOF

# Modify supabase-docker-compose/docker-compose.yml
python3 << 'PYEOF'
import re

with open('supabase-docker-compose/docker-compose.yml', 'r') as f:
    content = f.read()

# Remove "name: supabase"
content = re.sub(r'^name: supabase\s*\n', '', content, flags=re.MULTILINE)

# Comment the db data volume line and add new postgresql volume line
content = content.replace(
    '      - ./volumes/db/data:/var/lib/postgresql/data:Z',
    '      # - ./volumes/db/data:/var/lib/postgresql/data:Z\n      - ./postgresql:/var/lib/postgresql/data:Z'
)

# Add top-level networks before top-level volumes
if re.search(r'(?m)^networks:', content) is None:
    content = re.sub(
        r'(?m)^(volumes:)',
        'networks:\\n  default:\\n    name: odoo-supabase-net\\n    driver: bridge\\n\\n\\1',
        content
    )

with open('supabase-docker-compose/docker-compose.yml', 'w') as f:
    f.write(content)
PYEOF

# Modify odoo-19-docker-compose/docker-compose.yml
python3 << 'PYEOF'
import re

with open('odoo-19-docker-compose/docker-compose.yml', 'r') as f:
    content = f.read()

# Remove entire service "db"
content = re.sub(r'\n  db:\n.*?(?=\n  odoo19:)', '\n', content, flags=re.DOTALL)

# Replace command: --
content = content.replace(
    '    command: --',
    '    command: -- --database=${POSTGRES_DB}\n    # command: -- --database=${POSTGRES_DB} --with-demo   # uncomment to get database with demo data'
)

# Replace - HOST=db
content = content.replace(
    '      - HOST=db',
    '      - HOST=${POSTGRES_HOST}\n      - PORT=${POSTGRES_PORT}'
)

# Replace PASSWORD=odoo19@2025
content = content.replace(
    'PASSWORD=odoo19@2025',
    'PASSWORD=${POSTGRES_PASSWORD}'
)

# Add top-level networks at the end if not present
if re.search(r'(?m)^networks:', content) is None:
    content = content.rstrip() + '\n\nnetworks:\n  default:\n    name: odoo-supabase-net\n    driver: bridge\n'

with open('odoo-19-docker-compose/docker-compose.yml', 'w') as f:
    f.write(content)
PYEOF

# Combine Odoo 19 and Supabase Docker Compose
cp -r odoo-19-docker-compose/addons .
cp -r odoo-19-docker-compose/etc .
cp -r odoo-19-docker-compose/entrypoint.sh .
cp -r odoo-19-docker-compose/run.sh .
cp -r odoo-19-docker-compose/docker-compose.yml .

cp -r supabase-docker-compose/.env .
cp -r supabase-docker-compose/volumes .
cp -r supabase-docker-compose/docker-compose.yml ./dc-supabase.yml

# Merge docker-compose.yml and dc-supabase.yml into a single docker-compose.yml
python3 << 'PYEOF'
def parse_sections(content):
    sections = {}
    current_key = None
    current_lines = []
    for line in content.split('\n'):
        stripped = line.strip()
        if stripped and not stripped.startswith('#') and not line.startswith(' ') and not line.startswith('\t'):
            if current_key:
                sections[current_key] = '\n'.join(current_lines)
            current_key = stripped.rstrip(':')
            current_lines = []
        else:
            current_lines.append(line)
    if current_key:
        sections[current_key] = '\n'.join(current_lines)
    return sections

with open('docker-compose.yml', 'r') as f:
    odoo = parse_sections(f.read())

with open('dc-supabase.yml', 'r') as f:
    supabase = parse_sections(f.read())

# Merge services
merged_services = (odoo.get('services', '').strip('\n') + '\n' + supabase.get('services', '').strip('\n')).strip('\n')

# Keep one networks section (both are identical)
networks = (odoo.get('networks', '') or supabase.get('networks', '')).strip('\n')

# Keep volumes from supabase
volumes = supabase.get('volumes', '').strip('\n')

# Build merged output
output = 'services:\n' + merged_services + '\n'
if networks:
    output += '\nnetworks:\n' + networks + '\n'
if volumes:
    output += '\nvolumes:\n' + volumes + '\n'

with open('docker-compose.yml', 'w') as f:
    f.write(output)

import os
os.remove('dc-supabase.yml')
PYEOF

# Comment out all container_name attributes in the merged docker-compose.yml
sed -i 's/^\([[:space:]]*\)\(container_name:\)/\1# \2/g' docker-compose.yml
