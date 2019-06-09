# easyepg.minimal
A minimal docker container for running easyepg

## Prerequisites
You will need to have `docker` installed on your system and the user you want to run docker under needs to be in the `docker` group.

## Installation
As root user issue the following commands line by line to download a script and make it globally available:

``` 
curl -s https://raw.githubusercontent.com/dlueth/easyepg.minimal/master/eemd > /usr/local/sbin/eemd
chmod +x /usr/local/sbin/eemd
```

## Setup
Switch over to the user you want to run docker under and create (e.g.) a directory `easyepg` in its home folder.

Afterwards run `eemd setup ~/easyepg` to enter the docker container in setup-mode. When you finally see the container's prompt (it will download the image from docker on first run) issue `/entrypoint.sh` to start easyepg's setup.

When you are finished setting easyepg up to your liking exit the running docker container by issuing `exit`.

## First run
You should now be ready for your first run. Issue `eemd run ~/easyepg` from your command prompt to manually test if everything is working as expected. If it does you might want to create a cronjob!

## Cronjob
Still as the user you would like to run docker under issue `crontab -e` and put in the following lines

```
0 2 * * * eemd run ~/easyepg
0 4 * * * cat ~/easyepg/xml/[your file].xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
10 4 * * * cat ~/easyepg/xml/[your file].xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
```
