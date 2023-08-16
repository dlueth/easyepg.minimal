FROM python:3.9-slim-buster as base

ENV APT_DEPENDENCIES="build-essential ccache libfuse-dev upx scons git dh-autoreconf" \
    PIP_DEPENDENCIES="nuitka ordered-set pipreqs" \
    DEBIAN_FRONTEND="noninteractive" \
    TERM=xterm

RUN \
    ### tweak some apt & dpkg settings
    echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/docker-noinstall-recommends \
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
    ### install patchelf \
    && cd /tmp \
    && git clone https://github.com/brenoguim/patchelf.git \
    && cd patchelf \
    # && git checkout breno.474 \
    && ./bootstrap.sh \
    && mkdir build \
    && cd build \
    && ../configure \
    && make \
    && make install \
    ### setup python 3
    && python3 -m ensurepip \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install --no-cache --upgrade ${PIP_DEPENDENCIES}


FROM base as builder

ARG TARGETARCH
ENV WORKDIR=/var/app
WORKDIR ${WORKDIR}
COPY easyepg ${WORKDIR}/
COPY root /

RUN find . ! -name "easyepg.py" -type f -maxdepth 1 -exec rm -f {} + \
    && pipreqs ./ \
    && python3 -m pip install --no-cache --upgrade -r requirements.txt

RUN python3 -OO -m nuitka \
    --standalone \
    --follow-imports \
    --follow-stdlib \
    --prefer-source-code \
    --python-flag=-S,-OO \
    --plugin-enable=anti-bloat,implicit-imports,data-files,pylint-warnings \
    --include-data-dir=./resources/data=resources/data \
    --warn-implicit-exceptions \
    --warn-unusual-code \
    ./easyepg.py

RUN cd easyepg.dist/ \
    && mv ./easyepg.bin ./easyepg \
    && /usr/local/sbin/processLibs

RUN cd easyepg.dist/ \
    && strip --strip-unneeded --strip-debug easyepg \
    && upx --best --overlay=strip easyepg

RUN cd /var/dist \
    && cp -r ${WORKDIR}/easyepg.dist/* ./


FROM scratch

COPY --from=tarampampam/curl:latest /bin/curl /bin/curl
COPY --from=builder /var/dist/ /

HEALTHCHECK --interval=30s --timeout=6s --retries=5 --start-period=30s CMD [ \
    "/bin/curl", "--fail", "http://127.0.0.1:4000/" \
]

ENTRYPOINT [ "/easyepg" ]