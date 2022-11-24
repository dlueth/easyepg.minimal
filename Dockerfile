FROM python:3.10-slim-bullseye as base

ARG APT_DEPENDENCIES="build-essential ccache libfuse-dev patchelf upx"
ARG PIP_DEPENDENCIES="nuitka ordered-set pipreqs"
ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=xterm

RUN \
    ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split \
    && ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb  \
    && ln -s /bin/rm /usr/sbin/rm  \
    && ln -s /bin/tar /usr/sbin/tar \
    ### tweak some apt & dpkg settings
    && echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/docker-noinstall-recommends \
    && echo "APT::Install-Suggests "0";" >> /etc/apt/apt.conf.d/docker-noinstall-suggests \
    && echo "Dir::Cache "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "Dir::Cache::archives "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "path-exclude=/usr/share/locale/*" >> /etc/dpkg/dpkg.cfg.d/docker-nolocales \
    && echo "path-exclude=/usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/docker-noman \
    && echo "path-exclude=/usr/share/doc/*" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    && echo "path-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    ### install apt packages
    && apt-get -qy update \
    && apt-get install -qy ${APT_DEPENDENCIES} \
    ### setup python 3
    && python3 -m ensurepip \
    && python3 -m pip install --no-cache --upgrade ${PIP_DEPENDENCIES}

FROM base as builder

ARG WORKDIR=/var/app
WORKDIR ${WORKDIR}
ADD https://github.com/sunsettrack4/script.service.easyepg-lite/tarball/master ${WORKDIR}/
COPY root /

RUN \
    ### prepare build
    tar -xf master --strip 1 \
    && find . ! -name "easyepg.py" -type f -maxdepth 1 -exec rm -f {} + \
    && pipreqs ./ \
    && python3 -m pip install --no-cache --upgrade -r requirements.txt \
    ### run nuitka
    && python3 -OO -m nuitka \
        --standalone \
        --include-data-dir=./resources/data=resources/data \
        --follow-imports \
        --follow-stdlib \
        --nofollow-import-to=pytest \
        --python-flag=nosite,-OO \
        --plugin-enable=anti-bloat,implicit-imports,data-files,pylint-warnings \
        --warn-implicit-exceptions \
        --warn-unusual-code \
        --prefer-source-code \
        ./easyepg.py \
    ### add dynamic modules
    && cd easyepg.dist/ \
    && /processLibs.sh \
    ### run strip and upx
    && strip --strip-unneeded --strip-debug easyepg \
    && upx --best --overlay=strip easyepg

FROM scratch

COPY --from=builder /storage /storage
COPY --from=builder /var/app/easyepg.dist/ /

ENTRYPOINT [ "/easyepg" ]