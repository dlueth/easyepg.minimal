![GitHub release](https://img.shields.io/github/release/dlueth/easyepg.minimal.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/qoopido/easyepg.minimal.svg)

# easyepg.minimal
A minimal docker container for running easyepg either on demand or permanently with built-in cronjob

## Prerequisites
You will need to have `docker` installed on your system and the user you want to run it needs to be in the `docker` group.

## Installation
Switch to the user you want to run the container with and issue the following command to get everything up and running
```
sh -c "$(curl -s -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/dlueth/easyepg.minimal/master/init)"
```

> **Note:** The image is a multi-arch build providing variants for amd64, arm32v7 and arm64v8 - the correct variant for your architecture should<sup>TM</sup> be pulled automatically.

> **Note:** If the init-script successfully detects a valid `xmltv.sock` it will default to "yes" and provide the correct path automatically. Otherwise it will default to "no". 

## Initial setup
Switch to the user you want to run the container with and start the admin container and enter it via
```
docker start easyepg.admin
docker exec -ti easyepg.admin /bin/bash
```

After you successfully switched into the container issue
```
su - easyepg # skip if you are running the container as root
cd easyepg && ./epg.sh
```

to start easyepg's setup and configure it. When your setup is finished return to the shell and issue `exit` to leave the container followed by `docker stop easyepg.admin` to stop it.

## Updating EPG XML-files

### Variant A: via Cronjob in the container
Simply run the following command while logged in as the desired user
```
docker start easyepg.cron
```

There already is a crontab in the container that will run easyepg at 2:00am every night.

### Variant B: via Cronjob on the host
> **Note:** Skip this section if you decided to go with Variant A (e.g. you are running the container on a NAS)

Simply run the following command while logged in as the desired user
```
crontab -e
```

Append the following line to the file that should have been opened
```
0 2 * * * docker start easyepg.run 
```

If you did not set a path to `xmltv.sock` during installation you might need the following two lines in addition.
```
0 4 * * * cat ~/easyepg/xml/[your file].xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
10 4 * * * cat ~/easyepg/xml/[your file].xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
```
Replace `[your file]` with the filename of your generated XML.

Save and exit the file and you are done!
