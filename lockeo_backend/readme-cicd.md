# Lockeo Backend — CI/CD & DevSecOps

## 1. Présentation du projet

Lockeo est une application mobile développée dans le cadre du projet **MyDigitalStartup**.  
Dans le contexte du module **DevSecOps**, le travail a volontairement été concentré sur le **backend**, utilisé comme support réel pour la mise en place d’une chaîne CI/CD sécurisée.

Le backend prend la forme d’une **API REST**, développée avec **NestJS** et documentée via **Swagger**, permettant de tester facilement les endpoints et de valider le bon fonctionnement après chaque déploiement.

L’objectif du projet n’est pas de livrer une application complète côté front, mais de **démontrer une approche DevSecOps pragmatique**, appliquée à une brique applicative réelle.

---

## 2. Architecture globale

L’architecture repose sur une chaîne simple et maîtrisée :

- Développement local
- Dépôt GitHub (backend uniquement)
- CI/CD via GitHub Actions
- Image Docker sécurisée (multi-stage, non-root)
- Déploiement automatisé sur un VPS Linux

Le backend est exécuté dans un conteneur Docker, à partir d’une image construite et validée par la CI.  
Le serveur de production ne reconstruit rien : il se contente d’exécuter l’image fournie.

Les secrets (base de données, authentification registry, etc.) ne sont jamais versionnés et sont injectés via :
- les secrets GitHub Actions (CI/CD)
- un fichier `.env` présent uniquement sur le serveur

Cette séparation permet de limiter les risques et de garantir un environnement de production maîtrisé.

---

## 3. Pipeline CI/CD — Build, test et déploiement

La pipeline CI/CD est mise en place **uniquement sur le backend**, afin de réduire la surface d’attaque et de se concentrer sur les composants sensibles.

### 3.1 Build

- Construction d’une image Docker via un Dockerfile multi-stage
- Installation des dépendances de production uniquement
- Compilation de l’application
- Génération d’une image finale légère et épurée

### 3.2 Validation

- L’image Docker produite par la CI est l’artefact de référence
- L’API exposée via Swagger permet de vérifier le bon fonctionnement après déploiement
- La CI agit comme point de contrôle avant toute mise en production

### 3.3 Déploiement

- Déploiement automatisé via GitHub Actions
- Déclenchement uniquement si la CI est en succès et sur la branche `main`
- Connexion SSH vers le VPS
- Exécution de :
  - docker compose pull
  - docker compose up -d

Le déploiement est **reproductible**, car le serveur exécute exactement la même image Docker que celle validée par la CI.

---

## 4. CI/CD — Entrypoint Docker et migrations TypeORM

Ce document décrit le fonctionnement de `entrypoint.sh` et la gestion de l’exécution des migrations via la variable d’environnement `RUN_MIGRATIONS`.

### 4.1 Rôle de l’entrypoint

L’entrypoint (`lockeo_backend/entrypoint.sh`) exécute, dans cet ordre :

1. Attend que la base soit disponible (tentatives répétées sur `DB_HOST:DB_PORT`)
2. Applique les migrations (`npm run migration:run`) selon la stratégie définie
3. Démarre l’application (`node dist/main.js`)

### 4.2 Stratégie d’exécution des migrations

Le comportement est contrôlé via la variable d’environnement `RUN_MIGRATIONS` :

- `auto` (valeur par défaut) : exécute les migrations si `NODE_ENV=production`
- `true` : force l’exécution des migrations quel que soit l’environnement
- `false` : n’exécute jamais les migrations

Variables DB attendues :
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASS`
- `DB_NAME`

Note : côté Nest (`app.module.ts`), `migrationsRun` est actuellement activé en production.  
Si l’entrypoint ou la pipeline doivent être les seuls responsables des migrations, il est recommandé de basculer `migrationsRun` à `false`.

---

## 5. Exemples d’exécution

### 5.1 Docker run (manuel)

```bash
docker run --rm \
  -e NODE_ENV=production \
  -e RUN_MIGRATIONS=auto \
  -e DB_HOST=your-mysql \
  -e DB_PORT=3306 \
  -e DB_USER=lockeo \
  -e DB_PASS=secret \
  -e DB_NAME=lockeo \
  ghcr.io/<org>/lockeo-backend:latest


services:
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: lockeo
    ports:
      - "3306:3306"

  api:
    image: ghcr.io/<org>/lockeo-backend:latest
    environment:
      NODE_ENV: production
      RUN_MIGRATIONS: auto
      DB_HOST: db
      DB_PORT: 3306
      DB_USER: root
      DB_PASS: root
      DB_NAME: lockeo
    depends_on:
      - db
```
## 6. Pipeline CD — Job dédié aux migrations

Plutôt que d’exécuter les migrations au démarrage de chaque réplique, il est possible de :

- Lancer un job unique qui exécute npm run migration:run avec la même image Docker
- Déployer ou relancer les réplicas avec RUN_MIGRATIONS=false

Avantages :

- Pas de condition de course
- Logs centralisés
- Meilleur contrôle de l’ordre des opérations

## 7. Choix DevSecOps et bonnes pratiques

Les choix effectués dans ce projet répondent aux principes DevSecOps suivants :

- Sécurité intégrée dès la CI
- Image Docker sécurisée (multi-stage, non-root)
  
Séparation des responsabilités :

- CI : build, validation, déploiement
- Serveur : exécution uniquement
- Automatisation pour réduire les erreurs humaines
- Déploiement reproductible

## 8. Limites et axes d’amélioration

Dans un contexte plus avancé, plusieurs améliorations seraient possibles :

- Passage à un modèle GitOps (pull-based)
- Ajout de scans SAST / DAST bloquants
- Analyse automatique des vulnérabilités des images Docker
- Mise en place de monitoring et de centralisation des logs
