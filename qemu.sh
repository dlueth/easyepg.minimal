#!/bin/bash

for target_arch in aarch64 arm x86_64; do
  curl -sL https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0-2/x86_64_qemu-${target_arch}-static.tar.gz | tar -C ./root -xvf -
done
