# easyepg.minimal
A minimal docker container for running easyepg

## Prerequisites
You will need to have `docker` installed on your system and the user you want to run docker under needs to be in the `docker` group.

## Installation
As root user issue the following commands line by line to download a script and make it globally available:

``` 
curl -s https://raw.githubusercontent.com/dlueth/easyepg.minimal/feature/nas-support/eemd > /usr/local/sbin/eemd
chmod +x /usr/local/sbin/eemd
```

## Setup & Administration
Switch over to the user you want to run docker under and create (e.g.) a directory `easyepg` in its home folder.

Afterwards run `eemd admin ~/easyepg` to enter the docker container in admin-mode. When you finally see the container's prompt (it will download the image from docker on first run) issue `su - easyepg` followed by `./epg.sh` to start easyepg's setup.

When you are finished setting easyepg up to your liking exit the running docker container by issuing `exit`.

## First run
There are two ways of running the container depending on your surrounding environment/host.

### Directly 
Issue `eemd run ~/easyepg` from your command prompt to manually test if everything is working as expected. If it does you might want to create a cronjob on your local host machine:

Still as the user you would like to run docker under issue `crontab -e` and put in the following lines

```
0 2 * * * /usr/local/sbin/eemd run ~/easyepg
0 4 * * * cat ~/easyepg/xml/[your file].xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
10 4 * * * cat ~/easyepg/xml/[your file].xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
```

### NAS-System
On most NAS systems supporting docker, containers are supposed to be "always running" so the direct approach will most likely not work here.

There is another mode built-in to support thid type of system:

Issue `eemd cron ~/easyepg` to start the container updating epg information an 2am in the morning. This will take care of most things automatically.

If you are unable to run a container via shell script you may as well run it directly via

```
docker run --rm -ti -d \
  -e "MODE=cron" \
  -e "TZ=${TZ}" \ # Timezone, defaults to Europe/Berlin
  -e "PGID=${PGID}" \ # Group-ID, defaults to 1099 
  -e "PUID=${PUID}" \ # User-ID, defaults to 1099
  -v ${VOLUME}:/easyepg \ # Absolute (!) path to a shared directory storing easyepg & its settings
  --name easyepg-cron qoopido/easyepg.minimal:1.0.6-rc.1
```
