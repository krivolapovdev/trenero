# Build stage
FROM oven/bun:1.3.6-alpine AS build

WORKDIR /app

COPY web/package.json web/bun.lock ./

RUN bun install --frozen-lockfile --production

COPY web ./

ENV NODE_ENV=production

RUN bun run build

# Run stage
FROM nginx:1.29.4-alpine3.23

COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
