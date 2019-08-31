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

if [[ ! -f /easyepg/epg.sh ]]; then
  git clone https://github.com/${REPO}/easyepg.git /easyepg
  cd /easyepg
  git checkout ${BRANCH}
  cd /
  rm -rf /easyepg/.git /easyepg/.github
else
  if [[ "${UPDATE}" = "yes" ]]; then
    git clone https://github.com/${REPO}/easyepg.git /easyepg/easyepg
    cd /easyepg/easyepg
    git checkout ${BRANCH}
    cd /easyepg
    /bin/bash ./update.sh
    cd /
    rm -rf /easyepg/easyepg
  fi
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
    su ${USERNAME} -c "TERM=xterm /process.sh"
    ;;
  cron)
    sed -i "s/\${FREQUENCY}/${FREQUENCY}/" /easyepg.cron
    sed -i "s/\${USERNAME}/${USERNAME}/" /easyepg.cron
    crontab -u root /easyepg.cron
    exec /usr/sbin/cron -f -l 0
    ;;
  *)
    exec tail -f /dev/null
    ;;
esac
