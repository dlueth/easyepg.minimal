#!/bin/bash
set -e

if [[ -z "${TZ}" ]]; then
  TZ="Europe/Berlin"
fi

if [[ -z "${PGID}" ]]; then
  PGID="1099"
fi

if [[ -z "${PUID}" ]]; then
  PUID="1099"
fi

if [[ ! -f /easyepg/epg.sh ]]; then
  cd /easyepg
  git init .
  git remote add -f origin https://github.com/sunsettrack4/easyepg.git
  git checkout master
  git remote set-head origin -a
  cd /
else
  cd /easyepg
  git checkout -- .
  git pull
  cd /
fi

ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if ! grep -q ${PGID} /etc/group; then
  groupadd --gid ${PGID} easyepg
fi

if ! id -u easyepg &> /dev/null; then
  useradd --uid ${PUID} --gid ${PGID} --home /easyepg --shell /bin/bash easyepg
fi

chown -R ${PUID}:${PGID} /easyepg
chown -R ${PUID}:${PGID} /tmp

USERNAME=$(getent passwd ${PUID} | cut -d: -f1)

su ${USERNAME} -c "cd /easyepg && ./epg.sh"
