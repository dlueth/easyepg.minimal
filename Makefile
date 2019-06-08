build:
	docker build --compress --no-cache --force-rm --squash -t qoopido/easyepg.minimal:latest .

run:
	docker-compose up run

setup:
	docker-compose up -d setup
	docker exec -ti easyepg-setup /bin/bash
	docker stop easyepg-setup
