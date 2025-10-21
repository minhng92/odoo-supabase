# Odoo × Supabase

Odoo integration with Supabase's full feature set (Table/SQL editor, database management).

## Quick Installation

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) yourself, then run the following to set up first **Odoo-Supabase** instance @ `localhost:10019` (default credential: admin / admin | master password: minhng.info) and `localhost:8000` (default credential: supabase / minhng.info):

``` bash
# Default setup in target directory "odoo-supabase"
# Require available ports: 10019, 20019, 8000
curl -s https://raw.githubusercontent.com/minhng92/odoo-supabase/master/run.sh | bash
```

or run the following to set up **Odoo-Supabase** instance at specific ports @ `localhost:11019` and `localhost:9000`:

``` bash
curl -s https://raw.githubusercontent.com/minhng92/odoo-supabase/master/run.sh | bash -s odoo-supabase 11019 21019 9000
```

Some arguments:
* First argument (**odoo-supabase**): Target folder to deploy
* Second argument (**11019**): Odoo port
* Third argument (**21019**): Odoo live chat port
* Fourth argument (**9000**): Supabase Studio dashboard port

If `curl` is not found, install it:

``` bash
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
