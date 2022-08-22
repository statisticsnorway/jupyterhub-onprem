# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

include docker/jupyterhub/.env

.DEFAULT_GOAL=build

network:
	@docker network inspect $(DOCKER_NETWORK_NAME) >/dev/null 2>&1 || docker network create $(DOCKER_NETWORK_NAME)

volumes:
	@docker volume inspect $(DATA_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(DATA_VOLUME_HOST)
	@docker volume inspect $(DB_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(DB_VOLUME_HOST)


postgres-pw-gen:
	@echo "Generating postgres password in $@"
	@echo "POSTGRES_PASSWORD=$(shell openssl rand -hex 32)" > ~/secrets/postgres/postgres.env

# Do not require cert/key files if SECRETS_VOLUME defined
secrets_volume = $(shell echo $(SECRETS_VOLUME))
ifeq ($(secrets_volume),)
	cert_files=~/secrets/ssl/certificates.pem ~/secrets/ssl/starssb.key
else
	cert_files=
endif

check-files:  ~/secrets/postgres/postgres.env

pull:
	docker pull $(DOCKER_NOTEBOOK_IMAGE)

notebook_image: pull docker/jupyterlab/Dockerfile
	docker build -t $(LOCAL_NOTEBOOK_IMAGE) \
		--build-arg JUPYTERHUB_VERSION=$(JUPYTERHUB_VERSION) \
		--build-arg DOCKER_NOTEBOOK_IMAGE=$(DOCKER_NOTEBOOK_IMAGE) \
		jupyterlab

build: check-files network volumes
	docker-compose -f docker/jupyterhub/docker-compose.yml build

.PHONY: network volumes check-files pull notebook_image build
