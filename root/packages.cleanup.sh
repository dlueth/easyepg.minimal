#!/bin/bash

PWD=$(pwd)

apt-get -qy autoclean
apt-get -qy clean
apt-get -qy autoremove --purge
rm -rf ${CLEANUP}

cd ${PWD}
