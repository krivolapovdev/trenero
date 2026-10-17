up:
	docker buildx bake -f docker-bake.hcl --load
	docker compose -p trenerio -f docker-compose.yml up --force-recreate

down:
	docker compose -p trenerio down --remove-orphans

sqlc:
	cd ./server && sqlc generate

swag:
	cd ./server && swag init -g ./cmd/api/main.go -o docs
	cd ./client && rm -rf lib/generated
	cd ./client && dart run swagger_parser
	cd ./client && dart run build_runner build --build-filter="lib/generated/**"

slang:
	cd ./client && dart run slang
