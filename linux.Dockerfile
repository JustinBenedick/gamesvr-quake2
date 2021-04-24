# escape=`
FROM lacledeslan/steamcmd:linux as quake2-builder

ARG contentServer=content.lacledeslan.net

RUN echo "\nDownloading installer from $contentServer" &&`
        mkdir --parents /tmp &&`
        curl -sSL "http://content.lacledeslan.net/fastDownloads/_installers/quake2-3.20-glibc-i386-full-linux2.0.tar.bz2" -o /tmp/quake2.tar.bz2 &&`
    echo "Decompressing files" &&`
        cd /tmp &&`
        tar -xvjf /tmp/quake2.tar.bz2 --directory /output &&`
    echo "\nDownloading q2pro from $contentServer" &&`
        mkdir --parents /tmp &&`
        echo "\nDOWNLOADING q2PRO 64 BIT SERVER" &&`
        curl "http://content.lacledeslan.net/fastDownloads/_installers/q2proded-64" -o /output/q2pro_server_x64

#=======================================================================`
FROM debian:stable-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

EXPOSE 27910/udp

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        glib2.0 lib32gcc1 locales locales-all tmux zlib1g:i386 zlib1g &&`
    apt-get clean &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

LABEL maintainer="Laclede's LAN <contact @lacledeslan.com>" `
      com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="Quake2 Dedicated Server in Docker" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-quake2"

# Set up Enviornment
RUN useradd --home /app --gid root --system Quake2 &&`
    mkdir -p /app/ll-tests &&`
    chown Quake2:root -R /app;

# `RUN true` lines are work around for https://github.com/moby/moby/issues/36573
COPY --chown=Quake2:root --from=quake2-builder /output /app
RUN true

COPY --chown=Quake2:root ./dist/linux/ll-tests /app/ll-tests

RUN chmod +x /app/ll-tests/*.sh && chmod +x /app/q2pro_server_x64;

COPY --chown=Quake2:root ./dist/app /app/

USER Quake2

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
