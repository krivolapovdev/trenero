# Build stage
FROM --platform=$BUILDPLATFORM golang:1.27.2-alpine3.24 AS build

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ARG TARGETOS

ARG TARGETARCH

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o server .

# Run stage
FROM alpine:3.24.2

WORKDIR /app

RUN apk --no-cache add ca-certificates tzdata

COPY --from=build /app/server .

EXPOSE 8080

ENTRYPOINT ["./server"]
