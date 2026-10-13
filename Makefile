up:
	docker buildx bake -f docker-bake.hcl --load
	docker compose -p trenerio -f docker-compose.yml up --force-recreate

down:
	docker compose -p trenerio down --remove-orphans
