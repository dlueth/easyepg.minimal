#!/bin/bash
set -e
set -f

if [[ -z "${MODE}" ]]; then
  MODE="run"
fi

if [[ -z "${TIMEZONE}" ]]; then
  TIMEZONE="Europe/Berlin"
fi

if [[ -z "${GROUP_ID}" ]]; then
  GROUP_ID="1099"
fi

if [[ -z "${USER_ID}" ]]; then
  USER_ID="1099"
fi

if [[ -z "${FREQUENCY}" ]]; then
  FREQUENCY="0 2 * * *"
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
  git clone https://github.com/sunsettrack4/easyepg.git
  ./update.sh
  rm -rf ./easyepg
  cd /
fi

ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if ! grep -q ${GROUP_ID} /etc/group; then
  groupadd --gid ${GROUP_ID} easyepg
fi

if ! getent passwd ${USER_ID}; then
  useradd --uid ${USER_ID} --gid ${GROUP_ID} --home /easyepg --shell /bin/bash easyepg
fi

chown -R ${USER_ID}:${GROUP_ID} /easyepg
chown -R ${USER_ID}:${GROUP_ID} /tmp

USERNAME=$(getent passwd ${USER_ID} | cut -d: -f1)

case "${MODE}" in
  run)
    su ${USERNAME} -c "/process.sh"
    ;;
  cron)
    sed -i "s/\${FREQUENCY}/${FREQUENCY}/" /easyepg.cron
    crontab -u ${USERNAME} /easyepg.cron
    exec /usr/sbin/cron -f -l 0
    ;;
  *)
    exec tail -f /dev/null
    ;;
esac
