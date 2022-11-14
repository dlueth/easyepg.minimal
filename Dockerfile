FROM --platform=$BUILDPLATFORM python:slim-bullseye AS builder
ARG APT_DEPENDENCIES="build-essential bash zlib1g-dev git binutils patchelf upx"
ARG PIP_DEPENDENCIES="pip setuptools bottle requests xmltodict pyinstaller staticx"

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=xterm

COPY root/docker.py /tmp

RUN apt-get -qy update \
    ### tweak some apt & dpkg settings
    && echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/docker-noinstall-recommends \
    && echo "APT::Install-Suggests "0";" >> /etc/apt/apt.conf.d/docker-noinstall-suggests \
    && echo "Dir::Cache "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "Dir::Cache::archives "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "path-exclude=/usr/share/locale/*" >> /etc/dpkg/dpkg.cfg.d/docker-nolocales \
    && echo "path-exclude=/usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/docker-noman \
    && echo "path-exclude=/usr/share/doc/*" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    && echo "path-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    ### install dependencies
    && apt-get install -qy ${APT_DEPENDENCIES} \
    ### setup python 3
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade wheel scons \
    && pip3 install --no-cache --upgrade ${PIP_DEPENDENCIES} \
    ### build easyepg \
    && git clone --depth 1 --branch main https://github.com/sunsettrack4/script.service.easyepg-lite.git /tmp/easyepg \
    && cd /tmp/easyepg \
    && git checkout main \
    && mv /tmp/docker.py ./ \
    && python3 -OO -m PyInstaller --add-data="resources/data:resources/data" --name easyepg -F docker.py \
    && cd ./dist \
    && staticx --strip easyepg /easyepg \
    && cd / \
    && rm -rf /tmp/* \
    && mkdir -m 777 /storage \
    && chmod 777 /easyepg \
    && chmod +x /easyepg


FROM --platform=$BUILDPLATFORM scratch
LABEL maintainer="Dirk Lüth <dirk.lueth@gmail.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="easyepg.minimal"

ENTRYPOINT ["/easyepg"]
EXPOSE 4000

ADD root/tmp.tar /
COPY --from=builder /storage /storage
COPY --from=builder /easyepg /easyepg
