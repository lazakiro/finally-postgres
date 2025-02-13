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

# Detect docker compose command
DOCKER_COMPOSE := $(shell if command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; else echo "docker compose"; fi)

.PHONY: help setup start stop restart reload status logs health-check clean backup restore ps destroy purge

# Rest of the help target remains the same
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

# Modified targets to use $(DOCKER_COMPOSE)
start: setup
	@echo "${GREEN}Starting PostgreSQL container...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d

stop:
	@echo "${YELLOW}Stopping PostgreSQL container...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) stop

restart:
	@echo "${YELLOW}Restarting PostgreSQL container...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) restart

reload:
	@echo "${YELLOW}Reloading PostgreSQL container...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d

status:
	@echo "${GREEN}Checking container status...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

logs:
	@echo "${GREEN}Showing container logs...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE_NAME)

clean:
	@echo "${RED}Removing container and volumes...${NC}"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v