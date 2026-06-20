COMPOSE := docker compose -f .devcontainer/docker-compose.yml

.DEFAULT_GOAL := help

.PHONY: help up down shell claude run psql logs ps build rebuild clean logout

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-9s\033[0m %s\n", $$1, $$2}'

up: ## Start the dev environment (app + postgres) in the background
	$(COMPOSE) up -d

down: ## Stop the dev environment (keeps the database volume)
	$(COMPOSE) down

shell: up ## Open a bash shell inside the app container
	$(COMPOSE) exec app bash

claude: up ## Run Claude Code inside the app container (isolated from your host)
	$(COMPOSE) exec app claude

run: up ## Run the Go app inside the container (serves on :8080)
	$(COMPOSE) exec app go run .

psql: up ## Open a psql session against the Postgres container
	$(COMPOSE) exec db psql -U expense -d expense

logs: ## Tail logs from all services
	$(COMPOSE) logs -f

ps: ## Show running services
	$(COMPOSE) ps

build: ## Build the app image
	$(COMPOSE) build

rebuild: ## Rebuild the app image without cache
	$(COMPOSE) build --no-cache

clean: ## Stop containers and wipe ONLY the database (keeps your Claude login)
	$(COMPOSE) down
	-docker volume rm expense-app_pgdata

logout: ## Remove the in-container Claude login (forces re-login next time)
	$(COMPOSE) down
	-docker volume rm expense-app_claude-config
