TZ := $(shell cat /etc/timezone)
PGID := $(shell id -g `whoami`)
PUID := $(shell id -u `whoami`)

build:
	docker build --compress --no-cache --force-rm --squash -t qoopido/easyepg.minimal:latest .

run:
	TZ=$(TZ) PGID=$(PGID) PUID=$(PUID) docker-compose up run

setup:
	TZ=$(TZ) PGID=$(PGID) PUID=$(PUID) docker-compose up -d setup
	docker exec -ti easyepg-setup /bin/bash
	docker stop easyepg-setup
