build:
	docker build --compress --no-cache --force-rm --squash -t qoopido/easyepg.minimal:latest .

run:
	docker-compose up

setup:
	docker run -ti --rm -v /Users/dlueth/easyepg/volume:/easyepg --entrypoint=/bin/bash --name debug qoopido/easyepg.minimal:latest
