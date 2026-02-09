up:
	docker buildx bake -f docker-bake.hcl --load
	docker compose -p trenero -f docker-compose.yml -f docker-compose.dev.yml up --force-recreate

down:
	docker compose -p trenero down --remove-orphans
