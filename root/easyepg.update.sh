#!/bin/bash

PWD=$(pwd)

rm -rf /easyepg/easyepg
git clone https://github.com/${REPO}/easyepg.git /easyepg/easyepg

if [[ "${BRANCH}" != "master" ]]; then
  cd /easyepg/easyepg
  git checkout ${BRANCH}
fi

cd /easyepg
/bin/bash ./easyepg/update.sh
cd /
rm -rf /easyepg/easyepg

cd ${PWD}

