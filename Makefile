build:
	docker build --compress --no-cache --force-rm --squash -t easyepg:latest .

run:
	docker-compose up

debug:
	docker run -ti --rm -v /Users/dlueth/easyepg/volume:/easyepg --entrypoint=/bin/bash --name debug easyepg:latest
