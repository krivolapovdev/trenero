up:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --force-recreate --build

down:
	docker compose down --remove-orphans
