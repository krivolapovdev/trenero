# Build stage
FROM --platform=$BUILDPLATFORM golang:1.27.2-alpine3.24 AS build

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN sqlc generate

ARG TARGETOS

ARG TARGETARCH

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -tags release -o server ./cmd/api

# Run stage
FROM alpine:3.24.2

WORKDIR /app

RUN apk --no-cache add ca-certificates tzdata

COPY --from=build /app/server .

COPY --from=build /app/db/migrations ./db/migrations

ENV GIN_MODE=release

EXPOSE 8080

ENTRYPOINT ["./server"]
