![GitHub release](https://img.shields.io/github/release/dlueth/easyepg.minimal.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/qoopido/easyepg.minimal.svg)

# easyepg.minimal
A minimal docker container for running easyepg either on demand or permanently with built-in cronjob

## Manual installation via shell
> This section is not for users with a GUI interface for docker on a NAS system like Synology, UnRaid or OpenMediaVault (see [here](#technical-info-for-docker-guis-eg-synology-unraid-openmediavault) for details) but for people having a dedicated host running TVheadend directly but wanting to run easyepg as docker on this host. 

### Prerequisites
You will need to have `docker` installed on your system and the user you want to run it needs to be in the `docker` group.

### Installation
Switch to the user you want to run the container with and issue the following command to get everything up and running
```
sh -c "$(curl -s -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/dlueth/easyepg.minimal/master/init)"
```

> **Note:** The image is a multi-arch build providing variants for amd64, arm32v7 and arm64v8 - the correct variant for your architecture should<sup>TM</sup> be pulled automatically.

> **Note:** If the init-script successfully detects a valid `xmltv.sock` it will default to "yes" and provide the correct path automatically. Otherwise it will default to "no". 

### Initial setup
Switch to the user you want to run the container with and start the admin container and enter it via
```
docker start easyepg.admin
docker exec -ti -u easyepg -w /easyepg easyepg.admin /bin/bash ./epg.sh
```

to start easyepg's setup and configure it. When your setup is finished return to the shell and issue `exit` to leave the container followed by `docker stop easyepg.admin` to stop it.

> **Note:** If you did run the init-script as root user the container will not have an `easyepg` user and you will have remove the `-u easyepg` from the line above. I do not recommend this for security though.

### Updating EPG XML-files

#### Variant A: via Cronjob in the container
Simply run the following command while logged in as the desired user
```
docker start easyepg.cron
```

There already is a crontab in the container that will run easyepg at 2:00am every night.

#### Variant B: via Cronjob on the host
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

## Technical info for docker GUIs (e.g. Synology, UnRaid, OpenMediaVault)
To learn how to manually start the container or about available parameters (you might need for your GUI used) see the following example:

```
docker run \
  -d \
  -e MODE="admin" \
  -e USER_ID="1099" \
  -e GROUP_ID="1099" \
  -e TIMEZONE="Europe/Berlin" \
  -e FREQUENCY="0 2 * * *" \
  -e UPDATE="yes" \
  -e REPO="sunsettrack4" \
  -e BRANCH="master" \
  -e PACKAGES="" \
  -v {EASYEPG_STORAGE}:/easyepg \
  -v {XML_STORAGE}:/easyepg/xml \
  -v {XMLTV_SOCKET}:/xmltv.sock \
  --name=easyepg \
  --restart unless-stopped \
  --tmpfs /tmp \
  --tmpfs /var/log \
  qoopido/easyepg.minimal:latest
```

The available parameters in detail:

| Parameter | Optional | Values/Type | Default | Description |
| ---- | --- | --- | --- | --- |
| `MODE` | yes | run, admin, cron | run | Mode to run the container in |
| `USER_ID` | yes | [integer] | 1099 | UID to run easyepg as |
| `GROUP_ID` | yes | [integer] | 1099 | GID to run easyepg as |
| `TIMEZONE` | yes | [string] | Europe/Berlin | Timezone for the container |
| `FREQUENCY` | yes | [string] | 0 2 * * * | Cron frequency (when run in MODE='cron') |
| `UPDATE` | yes | yes, no | yes | Flag whether to update easyepg on container start |
| `REPO` | yes | sunsettrack4, DeBaschdi | sunsettrack4 | The repo to update/install easyepg from |
| `BRANCH` | yes | [string] | master | The branch to update/install easyepg from |
| `PACKAGES` | yes | [string] |  | Additional OS packages to install on container start |

Frequently used volumes:
 
| Volume | Optional | Description |
| ---- | --- | --- |
| `EASYEPG_STORAGE` | no | The directory to persist easyepg to |
| `XML_STORAGE` | yes | The directory to store the finished XML files in |
| `XMLTV_SOCKET` | yes | The socket to automatically write finished XMLs to |

When passing volumes please replace the name including the surrounding curly brackets with existing absolute paths with correct permissions.

If you decide to remove `XML_STORAGE` the finished XML files can be found in the `xml` subdirectory of `EASYEPG_STORAGE` instead.

> **Note:** `XML_STORAGE` can, e.g., be used to directly write finished XMLs into the directory you pass into a separately running TVheadend docker container. 

## Crontab syntax
```
 ┌───────────── minute (0 - 59)
 │ ┌───────────── hour (0 - 23)
 │ │ ┌───────────── day of month (1 - 31)
 │ │ │ ┌───────────── month (1 - 12)
 │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday;
 │ │ │ │ │                                       7 is also Sunday on some systems)
 │ │ │ │ │
 │ │ │ │ │
 * * * * *  /command/to/execute
```

