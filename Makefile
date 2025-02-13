# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Variables with defaults (overridable by .env)
COMPOSE_FILE ?= docker-compose.yml
SERVICE_NAME ?= postgres
CONTAINER_NAME ?= postgres
DATA_DIR ?= ./var/data
LOGS_DIR ?= ./var/logs
BACKUP_DIR ?= ./var/backups
SCRIPTS_DIR ?= ./var/init-scripts
DB_HOST ?= localhost
DB_PORT ?= 5432

# Colors
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
NC := \033[0m # No Color

.PHONY: help setup start stop restart reload status logs health-check clean backup restore ps

help:
	@echo "Available commands:"
	@echo "${GREEN}make setup${NC}         - Create necessary directories"
	@echo "${GREEN}make start${NC}         - Start PostgreSQL container"
	@echo "${GREEN}make stop${NC}          - Stop PostgreSQL container"
	@echo "${GREEN}make restart${NC}       - Restart PostgreSQL container"
	@echo "${GREEN}make reload${NC}        - Reload PostgreSQL container (down and up)"
	@echo "${GREEN}make status${NC}        - Check container status"
	@echo "${GREEN}make logs${NC}          - Show container logs"
	@echo "${GREEN}make health-check${NC}  - Check PostgreSQL health"
	@echo "${GREEN}make clean${NC}         - Remove container and volumes"
	@echo "${GREEN}make backup${NC}        - Backup PostgreSQL database"
	@echo "${GREEN}make restore${NC}       - Restore PostgreSQL database from backup"
	@echo "${GREEN}make ps${NC}            - List running containers"

setup:
	@echo "${GREEN}Creating project directories...${NC}"
	@mkdir -p $(DATA_DIR)
	@mkdir -p $(LOGS_DIR)
	@mkdir -p $(BACKUP_DIR)
	@mkdir -p $(SCRIPTS_DIR)
	@if [ ! -f .env ]; then \
		echo "Creating default .env file..."; \
		echo "POSTGRES_VERSION=16-alpine" > .env; \
		echo "CONTAINER_NAME=$(CONTAINER_NAME)" >> .env; \
		echo "SERVICE_NAME=$(SERVICE_NAME)" >> .env; \
		echo "DATA_DIR=$(DATA_DIR)" >> .env; \
		echo "LOGS_DIR=$(LOGS_DIR)" >> .env; \
		echo "BACKUP_DIR=$(BACKUP_DIR)" >> .env; \
		echo "SCRIPTS_DIR=$(SCRIPTS_DIR)" >> .env; \
		echo "DB_HOST=$(DB_HOST)" >> .env; \
		echo "DB_PORT=$(DB_PORT)" >> .env; \
		echo "POSTGRES_USER=app" >> .env; \
		echo "POSTGRES_DB=db" >> .env; \
		echo "NETWORK_NAME=postgres_network" >> .env; \
		echo "HEALTHCHECK_INTERVAL=10s" >> .env; \
		echo "HEALTHCHECK_TIMEOUT=5s" >> .env; \
		echo "HEALTHCHECK_RETRIES=5" >> .env; \
		echo "HEALTHCHECK_START_PERIOD=30s" >> .env; \
		echo "LOG_MAX_SIZE=10m" >> .env; \
		echo "LOG_MAX_FILES=3" >> .env; \
		echo "POSTGRES_PASSWORD=postgres" >> .env; \
	fi
	@echo "Created directories and .env template"

start: setup
	@echo "${GREEN}Starting PostgreSQL container...${NC}"
	docker-compose -f $(COMPOSE_FILE) up -d

stop:
	@echo "${YELLOW}Stopping PostgreSQL container...${NC}"
	docker-compose -f $(COMPOSE_FILE) stop

restart:
	@echo "${YELLOW}Restarting PostgreSQL container...${NC}"
	docker-compose -f $(COMPOSE_FILE) restart

reload:
	@echo "${YELLOW}Reloading PostgreSQL container...${NC}"
	docker-compose -f $(COMPOSE_FILE) down
	docker-compose -f $(COMPOSE_FILE) up -d

status:
	@echo "${GREEN}Checking container status...${NC}"
	docker-compose -f $(COMPOSE_FILE) ps

logs:
	@echo "${GREEN}Showing container logs...${NC}"
	docker-compose -f $(COMPOSE_FILE) logs -f $(SERVICE_NAME)

health-check:
	@echo "${GREEN}Checking PostgreSQL health...${NC}"
	@docker exec $(CONTAINER_NAME) pg_isready -U $${POSTGRES_USER:-app} -d $${POSTGRES_DB:-db} || exit 1

clean:
	@echo "${RED}Removing container and volumes...${NC}"
	docker-compose -f $(COMPOSE_FILE) down -v

backup:
	@echo "${GREEN}Creating database backup...${NC}"
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	docker exec $(CONTAINER_NAME) pg_dump -U $${POSTGRES_USER:-app} $${POSTGRES_DB:-db} > $(BACKUP_DIR)/backup_$$timestamp.sql && \
	echo "Backup created: $(BACKUP_DIR)/backup_$$timestamp.sql"

restore:
	@if [ -z "$(file)" ]; then \
		echo "${RED}Error: Please specify the backup file using file=<filename>${NC}"; \
		exit 1; \
	fi
	@echo "${YELLOW}Restoring database from $(file)...${NC}"
	@docker exec -i $(CONTAINER_NAME) psql -U $${POSTGRES_USER:-app} $${POSTGRES_DB:-db} < $(file)

ps:
	@echo "${GREEN}Listing running containers...${NC}"
	docker-compose -f $(COMPOSE_FILE) ps

destroy:
	@echo "${RED}Destroying container and volumes...${NC}"
	docker-compose -f $(COMPOSE_FILE) down -v
	@echo "${GREEN}Removing project directories...${NC}"

purge: destroy
	@echo "${RED}PURGING PROJECT...${NC}"
	rm -rf $(DATA_DIR) $(LOGS_DIR) $(BACKUP_DIR) $(SCRIPTS_DIR)
	@echo "${RED}Removing .env file...${NC}"
	rm -f .env