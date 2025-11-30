# syntax=docker/dockerfile:1.7

# 1) Dépendances de prod (rapides et légères)
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# 2) Build (TypeScript -> dist/)
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

# 3) Runner (prod)
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copie node_modules de prod + build
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package*.json ./

# Copy entrypoint
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

# Optionnel : healthcheck (assure-toi d'avoir une route /health)
# HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://127.0.0.1:3000/health || exit 1

# Sécurité basique : user non-root
RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
