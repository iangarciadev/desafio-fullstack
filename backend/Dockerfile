# Stage 1: build
FROM node:20-alpine AS builder
WORKDIR /app

RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm ci

COPY . .
RUN npx prisma generate
RUN npm run build

# Stage 2: production
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Necessário para os binários do Prisma no Alpine
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm ci --omit=dev

# App compilado
COPY --from=builder /app/dist ./dist

# Prisma: client gerado + engines
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma/engines ./node_modules/@prisma/engines

# Prisma CLI (devDep, necessário para o migrate deploy na inicialização)
COPY --from=builder /app/node_modules/.bin/prisma ./node_modules/.bin/prisma
COPY --from=builder /app/node_modules/prisma ./node_modules/prisma

# Schema para as migrations
COPY prisma ./prisma

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/index.js"]
