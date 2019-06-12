FROM debian:stretch-slim

LABEL maintainer="Dirk Lüth <dirk.lueth@gmail.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="easyepg.minimal"

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=xterm \
    LANGUAGE="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    BUILD_PATHS="/tmp/* /var/tmp/* /var/log/* /var/lib/apt/lists/* /var/lib/{apt,dpkg,cache,log}/ /var/cache/apt/archives /usr/share/doc/ /usr/share/man/ /usr/share/locale/" \
    BUILD_DEPENDENCIES="build-essential" \
    DEPENDENCIES="cron iproute2 procps phantomjs dialog curl wget git libxml2-utils perl perl-doc jq php php-curl xml-twig-tools liblocal-lib-perl inetutils-ping cpanminus"

COPY root/entrypoint.sh /entrypoint.sh
COPY root/easyepg /etc/cron.d/easyepg

RUN apt-get -qy update \
    ### tweak some apt & dpkg settngs
    && echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/docker-noinstall-recommends \
    && echo "APT::Install-Suggests "0";" >> /etc/apt/apt.conf.d/docker-noinstall-suggests \
    && echo "Dir::Cache "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "Dir::Cache::archives "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "path-exclude=/usr/share/locale/*" >> /etc/dpkg/dpkg.cfg.d/docker-nolocales \
    && echo "path-exclude=/usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/docker-noman \
    && echo "path-exclude=/usr/share/doc/*" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    && echo "path-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    ### install basic packages
    && apt-get install -qy apt-utils locales tzdata \
    ### limit locale to en_US.UTF-8
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && locale-gen --purge en_US.UTF-8 \
    ### run dist-upgrade
    && apt-get dist-upgrade -qy \
    ### install easyepg dependencies
    && apt-get install -qy ${BUILD_DEPENDENCIES} ${DEPENDENCIES} \
    && cpan App:cpanminus \
    && cpanm install JSON \
    && cpanm install XML::Rules \
    && cpanm install XML::DOM \
    && cpanm install Data::Dumper \
    && cpanm install Time::Piece \
    && cpanm install Time::Seconds \
    && cpanm install DateTime \
    && cpanm install DateTime::Format::DateParse \
    && cpanm install utf8 \
    && mkdir -p /easyepg \
    && chmod +x /entrypoint.sh \
    && chmod 644 /etc/cron.d/easyepg \
    ### cleanup
    && apt-get remove --purge -qy ${BUILD_DEPENDENCIES} \
    && apt-get -qy autoclean \
    && apt-get -qy clean \
    && apt-get -qy autoremove --purge \
    && rm -rf ${BUILD_PATHS}

ENTRYPOINT [ "/entrypoint.sh" ]
