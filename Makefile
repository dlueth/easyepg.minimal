ROOT := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent

clean:
	rm -rf ./binaries/*
	docker ps --format "{{.Image}} {{.ID}}" | grep "python" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "python" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker images --format "{{.Repository}}:{{.ID}}" | grep "python" | sed -n -e "s/^python://p" | xargs -I {} docker rmi --force {} > /dev/null
	docker ps --format "{{.Image}} {{.ID}}" | grep "tarampampam/curl" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "tarampampam/curl" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker images --format "{{.Repository}}:{{.ID}}" | grep "tarampampam/curl" | sed -n -e "s/^tarampampam\/curl://p" | xargs -I {} docker rmi --force {} > /dev/null
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/easyepg.minimal" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/easyepg.minimal" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker images --format "{{.Repository}}:{{.ID}}" | grep "qoopido/easyepg.minimal" | sed -n -e "s/^qoopido\/easyepg.minimal://p" | xargs -I {} docker rmi --force {} > /dev/null

build:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --no-cache --compress --push -t qoopido/easyepg.minimal:lite-scratch .

#############################
# Argument fix workaround
#############################
%:
	@:
