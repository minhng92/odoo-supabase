#!/bin/bash
DESTINATION=${1:-odoo-supabase}
ODOO_PORT=${2:-10019}
ODOO_CHAT=${3:-20019}
DASHBOARD_PORT=${4:-8000}

# Clone Odoo-Supabase directory
git clone --depth=1 https://github.com/minhng92/odoo-supabase $DESTINATION
rm -rf $DESTINATION/.git

# Create PostgreSQL directory
mkdir -p $DESTINATION/postgresql

# Change ownership to current user and set restrictive permissions for security
sudo chown -R $USER:$USER $DESTINATION
sudo chmod -R 700 $DESTINATION  # Only the user has access

# Check if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Running on macOS. Skipping inotify configuration."
else
  # System configuration
  if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then
    echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf)
  else
    echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf
  fi
  sudo sysctl -p
fi

# Set ports in docker-compose.yml
# Update docker-compose configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS sed syntax
  sed -i '' 's/10019/'$ODOO_PORT'/g' $DESTINATION/docker-compose.yml
  sed -i '' 's/20019/'$ODOO_CHAT'/g' $DESTINATION/docker-compose.yml
  sed -i '' 's/KONG_HTTP_PORT=8000/KONG_HTTP_PORT='$DASHBOARD_PORT'/g' $DESTINATION/.env
else
  # Linux sed syntax
  sed -i 's/10019/'$ODOO_PORT'/g' $DESTINATION/docker-compose.yml
  sed -i 's/20019/'$ODOO_CHAT'/g' $DESTINATION/docker-compose.yml
  sed -i 's/KONG_HTTP_PORT=8000/KONG_HTTP_PORT='$DASHBOARD_PORT'/g' $DESTINATION/.env
fi

# Set file and directory permissions after installation
find $DESTINATION -type f -exec chmod 644 {} \;
find $DESTINATION -type d -exec chmod 755 {} \;

chmod +x $DESTINATION/entrypoint.sh

# Run Odoo
if ! is_present="$(type -p "docker-compose")" || [[ -z $is_present ]]; then
  docker compose -f $DESTINATION/docker-compose.yml up -d
else
  docker-compose -f $DESTINATION/docker-compose.yml up -d
fi


echo "Odoo started at http://localhost:$ODOO_PORT | Default User: admin | Default Password: admin | Live chat port: $ODOO_CHAT"
echo "Supabase Studio started at http://localhost:$DASHBOARD_PORT | Dashboard User: supabase | Dashboard Password: minhng.info"