# Odoo × Supabase

Odoo integration with Supabase's full feature set (Table/SQL editor, database management).

## Usage

```bash
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
<img src="/screenshots/table-editor.jpg" width="100%">
</p>

<p>
<img src="/screenshots/sql-editor.jpg" width="100%">
</p>

<p>
<img src="/screenshots/database-table.jpg" width="100%">
</p>
