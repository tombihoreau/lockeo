# CI/CD — Entrypoint Docker et migrations TypeORM

Ce document décrit le fonctionnement de `entrypoint.sh` et comment piloter l’exécution des migrations via la variable d’environnement `RUN_MIGRATIONS`.

## Rôle de l’entrypoint

L’entrypoint (`lockeo_backend/entrypoint.sh`) exécute, dans cet ordre:
1. Attend que la base soit disponible (tentatives répétées sur `DB_HOST:DB_PORT`).
2. Applique les migrations (`npm run migration:run`) selon la stratégie ci-dessous.
3. Démarre l’application (`node dist/main.js`).

## Stratégie d’exécution des migrations

Contrôle via la variable d’environnement `RUN_MIGRATIONS`:
- `auto` (valeur par défaut): exécute les migrations si `NODE_ENV=production`.
- `true`: force l’exécution des migrations quel que soit l’environnement.
- `false`: n’exécute jamais les migrations.

Variables DB attendues:
- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME`

Note: côté Nest (app.module.ts), `migrationsRun` est actuellement activé en prod. Si vous souhaitez que l’entrypoint/pipeline soit l’unique responsable des migrations, basculez `migrationsRun` à `false` en production.

## Exemples

### Docker run (manuel)

```bash
# Production-like
docker run --rm \
  -e NODE_ENV=production \
  -e RUN_MIGRATIONS=auto \
  -e DB_HOST=your-mysql \
  -e DB_PORT=3306 \
  -e DB_USER=lockeo \
  -e DB_PASS=secret \
  -e DB_NAME=lockeo \
  ghcr.io/<org>/lockeo-backend:latest
```

### Docker Compose (service)

```yaml
services:
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: lockeo
    ports: ["3306:3306"]
  api:
    image: ghcr.io/<org>/lockeo-backend:latest
    environment:
      NODE_ENV: production
      RUN_MIGRATIONS: auto  # true/false/auto
      DB_HOST: db
      DB_PORT: 3306
      DB_USER: root
      DB_PASS: root
      DB_NAME: lockeo
    depends_on:
      - db
```

### Pipeline CD (job dédié migrations)

Plutôt que de confier les migrations au démarrage de chaque réplique, on peut :
1) Lancer un job unique qui exécute `npm run migration:run` (avec la même image),
2) Déployer/relancer les réplicas avec `RUN_MIGRATIONS=false`.

Avantages: pas de condition de course, logs centralisés, contrôle fin de l’ordre des opérations.

## Bonnes pratiques

- Production/staging: privilégier un job/entrypoint dédié aux migrations, et désactiver `migrationsRun` côté app pour éviter les doublons.
- Multi-réplicas: éviter que chaque réplique tente d’exécuter les migrations; orchestrer via un job unique.
- CI: exécuter les migrations sur une base éphémère avant les tests pour détecter les problèmes en amont.
- Dev: vous pouvez utiliser `DB_SYNCHRONIZE=true` (et `DB_DROP_SCHEMA=true` si besoin) pour itérer vite, mais générez des migrations avant toute mise en prod.

## Dépannage

- L’entrypoint boucle trop longtemps: vérifier que `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS` permettent une connexion au serveur MySQL.
- Erreurs de migration: lancez localement `npm run migration:run` avec les mêmes variables d’environnement pour reproduire et investiguer.
- Changements d’entités non migrés: générez une migration (`npm run typeorm -- migration:generate src/database/migrations/MeaningfulName`) et committez-la.
