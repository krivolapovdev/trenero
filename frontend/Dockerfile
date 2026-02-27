# Build stage
FROM oven/bun:1.3.6-alpine AS build

WORKDIR /app

COPY web/package.json web/bun.lock ./

RUN bun install --frozen-lockfile --production

COPY web ./

ENV NODE_ENV=production

RUN bun run build

# Run stage
FROM oven/bun:1.3.6-alpine

WORKDIR /app

COPY --from=build /app/dist ./

COPY web/src/index.ts ./

ENV NODE_ENV=production

EXPOSE 3000

CMD ["bun", "run", "index.ts"]
