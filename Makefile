#!/bin/bash

RELEASE := latest

ifneq ($(wildcard .git),)
version ?= latest
else 
version ?= $(shell git rev-parse --abbrev-ref HEAD)
endif
export version

docker-compose-command := docker-compose --project-directory=.
docker-compose := $(docker-compose-command) -f docker/docker-compose.yml

line-length := 120


# make .env file from .env.example (-p means prevent overwriting orginal file )
copy_env = cp -p docker/.env.example  
.PHONY: help
help:
	@echo "Makefile for houe_sell"
	@echo
	@echo "Usage: "
	@echo "		make build		- Build a Docker Image for house_sell backend"
	@echo "						  excuted automatically before run-"
	@echo
	@echo "		make run		- run house_sell backend and dependent services"
	@echo "		make test-dev		- start all dependencies then run the test suite"
	@echo "		make stop		- stop all MD containers currently running"
	@echo 
	@echo "Advanced:"
	@echo "		make clean		- stop and remove all MD related containers"
	@echo "		make requirements - convert requirements/*.in to requirements/.txt via pip-compile"
	@echo
	@echo "		make migration name='name_of_migration_file' app='app_name' "
	@echo "	 			- Make Django migrations pass the name of migration as well" 
	@echo "				  as the app name"
	@echo
	@echo "		make migrate	 - Apply latest migration"
	@echo
	@echo "		make createsuperuser - Create Django superuser"
	@echo
	@echo "		make flake		 - Using flake"
	@echo "		make black-check	 - Check if there is anything needs to be re-formatted by black"
	@echo "		make black		 - code formatting"
	@echo "		make isort		 - sort imports alphabetically, and automatically separated into sections and by type"

.PHONY: build
build:
	@echo `git symbolic-ref -q --short HEAD || git describe --tags --exact-match` > .appversion
	@echo `git rev-parse HEAD` > .gitcommit
	@echo `git describe --tags` > .apprelease
	@printf "\nBuilding image on "`cat .appversion`" / "`cat .apprelease`".\n\n"
	$(docker-compose) build

.PHONY: up
up:
	$(docker-compose) up --force-recreate --remove-orphans

.PHONY: run
run: stop clean build up

.PHONY: run-dev
run-dev:stop clean
	$(docker-compose) run \
		--name hamy \
		-e DJANGO_SETTINGS_MODULE=hamy.settings \
		-e version=${version} \
		-v `pwd`:/hamy\
		-p 8002:8002 \
		backend dev

.PHONY: test-dev
test-dev: stop build clean
	$(docker-compose) run \
		-e DJANGO_SETTINGS_MODULE=house_sell.settings.testing \
		-v `pwd`:/house-sell\
		-p 8002:8002 \
		--name house-sell \
		backend test

# alias for convenience
.PHONY: env
env: docker/.env

.PHONY: stop
stop:
	@$(docker-compose) stop
	@(docker ps -q -f 'name=hamy*' | xargs docker stop 2>&1) >/dev/null || true
	@echo "Containers stopped."

.PHONY: clean
clean:
	@$(docker-compose) rm -f
	@(docker ps -q -f 'name=hamy*' | xargs docker rm 2>&1) >/dev/null || true
	docker rm -fv hamy || true
	@echo "Containers removed."

.PHONY: migration
migration:
	docker exec -ti hamy python manage.py makemigrations \
	--name $(name) $(app)
	
.PHONY: migrate
migrate:
	docker exec -ti hamy python manage.py migrate

.PHONY: createsuperuser
createsuperuser:
	docker exec -ti hamy python manage.py createsuperuser

.PHONY: requirements
.ONESHELL:
# requirements:
# 	@if [ `command -v pip install - ./requirements/base.txt` ]; then
# 		printf "Regenerating requirements files... "
# 		for r in requirements/*.txt ; do
# 			r="$${r%.*}"
# 			pip-compile --output-file ./$${r}.txt ./$${r}.in  >/dev/null
# 		done
# 		printf "done.\n"
# 	else
# 		echo "Tried to regenerate requirements, but pip-compile not found."
# 		echo "This is only a problem if you changed the requirements; ignore this message otherwise."
# 	fi

.PHONY: flake
flake:
	flake8

.PHONY: black-check
.ONESHELL:
black-check:
	@(black --check --line-length=${line-length} $(path) >/dev/null)

.PHONY: black
.ONESHELL:
black:
	@if ! ( black --check --line-length=${line-length} $(path) >/dev/null  ); then
		echo "The following files need to be re-formatted in the following ways:"
		black --diff --line-length=${line-length} $(path)
		echo "Continue? (y/n)"
		read line
		if [ $$line = "Y" ] || [ $$line = "y" ]; then
			echo "Black formating..."
			exec black --line-length=${line-length} $(path)
		else
			echo "Leaving the files untouched."
		fi
	else
		echo "No need to re-format anything"
	fi

.PHONY: isort
.ONESHELL:
isort:
	@if ! ( isort --line-length=${line-length} $(path) -c >/dev/null  ); then
		echo "The following files imports need to be sorted in the following ways:"
		isort --line-length=${line-length} $(path) --diff
		echo "Continue? (y/n)"
		read line
		if [ $$line = "Y" ] || [ $$line = "y" ]; then
			echo "Sorting the imports..."
			isort --line-length=${line-length} $(path)
		else
			echo "Leaving the files untouched."
		fi
	else
		echo "No need to sort anything"
	fi
