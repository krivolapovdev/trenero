up:
	docker buildx bake -f docker-bake.hcl --load
	docker compose -p trenerio -f docker-compose.yml up --force-recreate

down:
	docker compose -p trenerio down --remove-orphans

sqlc:
	cd ./server && sqlc generate

swag:
	cd ./server && swag init -d ./cmd/api,./internal,./pkg -g main.go -o docs
