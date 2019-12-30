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

if [[ -z "${UPDATE}" ]]; then
  UPDATE="yes"
fi

if [[ -z "${REPO}" ]]; then
  REPO="sunsettrack4"
fi

if [[ -z "${BRANCH}" ]]; then
  BRANCH="master"
fi

if [[ ! -f /easyepg/update.sh ]]; then
  /easyepg.install.sh
else
  if [[ "${UPDATE}" = "yes" ]]; then
    /easyepg.update.sh
  fi
fi

ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo ${TIMEZONE} > /etc/timezone

if ! getent passwd ${USER_ID}; then
  adduser -D -g "" -u ${USER_ID} -h /easyepg -s /bin/bash easyepg
fi

if ! getent group ${GROUP_ID}; then
  GROUP_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w ${1:-16} | head -n 1)

  addgroup -g ${GROUP_ID} ${GROUP_NAME}
  addgroup easyepg ${GROUP_NAME}
fi

chown -R ${USER_ID}:${GROUP_ID} /easyepg
chown -R ${USER_ID}:${GROUP_ID} /tmp

USERNAME=$(getent passwd ${USER_ID} | cut -d: -f1)

if [[ ! -z "${PACKAGES}" ]]; then
  /packages.install.sh
  /packages.cleanup.sh
fi

case "${MODE}" in
  run)
    su ${USERNAME} -c "TERM=xterm /process.sh"
    ;;
  cron)
    sed -i "s/\${FREQUENCY}/${FREQUENCY}/" /easyepg.cron
    sed -i "s/\${USERNAME}/${USERNAME}/" /easyepg.cron
    crontab -u root /easyepg.cron
    exec /usr/sbin/crond -f -l 0
    ;;
  *)
    exec tail -f /dev/null
    ;;
esac
