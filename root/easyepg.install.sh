#!/bin/bash

PWD=$(pwd)

rm -rf /easyepg/*
git clone https://github.com/${REPO}/easyepg.git /easyepg

if [[ "${BRANCH}" != "master" ]]; then
  cd /easyepg
  git checkout ${BRANCH}
fi

cd /
rm -rf /easyepg/.git*

cd ${PWD}

