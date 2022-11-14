![GitHub release](https://img.shields.io/github/release/dlueth/easyepg.minimal.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/qoopido/easyepg.minimal.svg)

# easyepg.minimal
A minimal docker container for running easyepg 

### Prerequisites
You will need to have `docker` installed on your system and the user you want to run it needs to be in the `docker` group.

> **Note:** The image is a multi-arch build providing variants for amd64, arm32v7 and arm64v8 - the correct variant for your architecture should<sup>TM</sup> be pulled automatically.

### Initial setup

## Technical info for docker GUIs (e.g. Synology, UnRaid, OpenMediaVault)
To learn how to manually start the container or about available parameters (you might need for your GUI used) see the following example:

```
docker run \
  -d \
  -p 4000:4000 \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v {EASYEPG_STORAGE}:/easyepg \
  -v {XML_STORAGE}:/easyepg/xml \
  --user=${UID}:${GID} \
  --name=easyepg \
  --restart unless-stopped \
  --net="bridge" \
  qoopido/easyepg.minimal:alpha
```

Used volumes:

| Volume            | Optional | Description                                      |
|-------------------|----------|--------------------------------------------------|
| `EASYEPG_STORAGE` | no       | The directory to persist easyepg to              |
| `XML_STORAGE`     | yes      | The directory to store the finished XML files in |

When passing volumes please replace the name including the surrounding curly brackets with existing absolute paths with correct permissions.

If you decide to remove `XML_STORAGE` the finished XML files can be found in the `xml` subdirectory of `EASYEPG_STORAGE` instead.

> **Note:** `XML_STORAGE` can, e.g., be used to directly write finished XMLs into the directory you pass into a separately running TVheadend docker container.
