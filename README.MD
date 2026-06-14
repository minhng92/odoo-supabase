# Odoo × Supabase

Odoo integration with Supabase's full feature set (Table/SQL editor, database management).

## Quick Installation

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) yourself, then run the following to set up an **Odoo-Supabase** instance.

### Default setup

Deploy to `odoo-supabase` with Odoo at `localhost:10019`, live chat at `localhost:20019`, and Supabase Studio at `localhost:8000` (default credentials: Odoo admin / admin | master password: minhng.info; Supabase Studio supabase / minhng.info):

```bash
# Require available ports: 10019, 20019, 8000
curl -s https://raw.githubusercontent.com/minhng92/odoo-supabase/master/run.sh | bash -s -- --destination odoo-supabase --port 10019 --chat 20019
```

### Custom ports and options

Deploy to a custom destination with custom ports:

```bash
curl -s https://raw.githubusercontent.com/minhng92/odoo-supabase/master/run.sh | bash -s -- --destination odoo-supabase --port 11019 --chat 21019 --kong-port 9000
```

All available arguments:

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--destination` | Yes | | Target folder to deploy |
| `--port` | Yes | | Odoo port |
| `--chat` | Yes | | Odoo live chat port |
| `--kong-port` | No | `8000` | Supabase Studio dashboard port |
| `--password` | No | `minhng.info` | Odoo master password |
| `--db-password` | No | (from compose) | PostgreSQL password |

If `curl` is not found, install it:

```bash
$ sudo apt-get install curl
# or
$ sudo yum install curl
```

## Usage

```bash
git clone git@github.com:minhng92/odoo-supabase.git
cd odoo-supabase
docker-compose up -d
```

## Configuration

- **Database**: Initializes `POSTGRES_DB=odooxsupabase` for both Odoo and Supabase by default. Change the database name in `.env` if needed.
- **Demo Data**: To set up Odoo with demo data, uncomment the second `command` in `docker-compose.yml`.
- **Limitation**: Multiple databases are not supported.

## Access Points

| Service | Credential | URL | Notes |
|---------|-----|-----|-------|
| Odoo | admin / admin | http://localhost:10019 | Main application. |
| Odoo Live Chat | | http://localhost:20019 | Chat service |
| Supabase Studio | supabase / minhng.info | http://localhost:8000 | Defined by `DASHBOARD_USERNAME`, `DASHBOARD_PASSWORD` and `KONG_HTTP_PORT` in `.env` |

> **Note**: Change / Expose ports in configuration files (docker-compose.yml) if needed.

# Screenshots

<p>
<img src="/screenshots/odoo-19-apps-screenshot.jpg" width="100%">
</p>

<p>
<img src="/screenshots/table-editor.jpg" width="100%">
</p>

<p>
<img src="/screenshots/sql-editor.jpg" width="100%">
</p>

<p>
<img src="/screenshots/database-table.jpg" width="100%">
</p>
