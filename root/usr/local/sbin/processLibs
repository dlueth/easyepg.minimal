#!/bin/sh

ARCH=$(uname -m)

if [ "${ARCH}" = "x86_64" ]
then
  ldd easyepg | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --no-clobber -v '{}' .
  ldd easyepg | grep "/lib64/ld-linux-x86-64" | awk '{print $1}' | xargs -I '{}' cp --parents -v '{}' .
  cp --no-clobber -v /lib/x86_64-linux-gnu/libgcc_s.so.1 .
  mkdir -p ./lib/x86_64-linux-gnu
  cp --no-clobber -v /lib/x86_64-linux-gnu/libresolv* ./lib/x86_64-linux-gnu
  cp --no-clobber -v /lib/x86_64-linux-gnu/libnss_dns* ./lib/x86_64-linux-gnu
fi

if [ "${ARCH}" = "aarch64" ]
then
  ldd easyepg | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --no-clobber -v '{}' .
  ldd easyepg | grep "/lib/ld-linux-aarch64" | awk '{print $1}' | xargs -I '{}' cp --parents -v '{}' .
  cp --no-clobber -v /lib/aarch64-linux-gnu/libgcc_s.so.1 .
  mkdir -p ./lib/aarch64-linux-gnu
  cp --no-clobber -v /lib/aarch64-linux-gnu/libresolv* ./lib/aarch64-linux-gnu
  cp --no-clobber -v /lib/aarch64-linux-gnu/libnss_dns* ./lib/aarch64-linux-gnu
fi

if [ "${ARCH}" = "armv7l" ]
then
  ldd easyepg | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --no-clobber -v '{}' .
  ldd easyepg | grep "/lib/ld-linux-armhf" | awk '{print $1}' | xargs -I '{}' cp --parents -v '{}' .
  cp --no-clobber -v /lib/arm-linux-gnueabihf/libgcc_s.so.1 .
  mkdir -p ./lib/arm-linux-gnueabihf
  cp --no-clobber -v /lib/arm-linux-gnueabihf/libresolv* ./lib/arm-linux-gnueabihf
  cp --no-clobber -v /lib/arm-linux-gnueabihf/libnss_dns* ./lib/arm-linux-gnueabihf
fi