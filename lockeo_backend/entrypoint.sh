#!/usr/bin/env sh
set -e

# Simple wait-for-DB using mysql2 via Node (works on node:alpine without extra packages)
wait_for_db() {
  echo "Waiting for DB ${DB_HOST:-127.0.0.1}:${DB_PORT:-3306}..."
  ATTEMPTS=60
  i=1
  while [ $i -le $ATTEMPTS ]; do
    node -e '
      const mysql = require("mysql2/promise");
      (async () => {
        try {
          const conn = await mysql.createConnection({
            host: process.env.DB_HOST || "127.0.0.1",
            port: Number(process.env.DB_PORT || 3306),
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
          });
          await conn.end();
          process.exit(0);
        } catch (e) {
          process.exit(1);
        }
      })();
    ' && break
    echo "DB not ready yet... ($i/$ATTEMPTS)"
    i=$((i+1))
    sleep 1
  done
  if [ $i -gt $ATTEMPTS ]; then
    echo "Database not reachable after $ATTEMPTS seconds" >&2
    exit 1
  fi
}

# Only run migrations if explicitly enabled or in production
RUN_MIGRATIONS=${RUN_MIGRATIONS:-auto}
# auto: run when NODE_ENV=production; true/false: force behavior

wait_for_db

if [ "$RUN_MIGRATIONS" = "true" ] || { [ "$RUN_MIGRATIONS" = "auto" ] && [ "$NODE_ENV" = "production" ]; }; then
  echo "Running migrations..."
  npm run migration:run
else
  echo "Skipping migrations (RUN_MIGRATIONS=$RUN_MIGRATIONS, NODE_ENV=$NODE_ENV)"
fi

# Start app
exec node dist/main.js
