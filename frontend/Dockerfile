# Build stage
FROM oven/bun:1.3.6-alpine AS build

WORKDIR /app

COPY web/package.json web/bun.lock ./

RUN bun install --frozen-lockfile --production

COPY web ./

ENV NODE_ENV=production

RUN bun run build

# Run stage
FROM busybox:1.37.0

WORKDIR /app

COPY --from=build /app/dist ./

EXPOSE 3000

CMD ["httpd", "-f", "-v", "-p", "3000"]
