up:
	docker buildx bake -f docker-bake.hcl --load
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --force-recreate

down:
	docker compose down --remove-orphans
