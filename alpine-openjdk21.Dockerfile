FROM alpine:latest

LABEL dockerhub="https://hub.docker.com/r/antlafarge/jdownloader" \
      github="https://github.com/antlafarge/jdownloader" \
      maintainer.name="Antoine Lafarge" \
      maintainer.email="ant.lafarge@gmail.com" \
      maintainer.github="https://github.com/antlafarge" \
      maintainer.dockerhub="https://hub.docker.com/u/antlafarge"

STOPSIGNAL SIGTERM

ENV JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_DEVICENAME="" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    LOG_FILE="/dev/null" \
    JAVA_OPTIONS="" \
    UMASK=""

RUN apk update \
 && apk -U upgrade \
 && apk add --no-cache \
    bash \
    curl \
    ffmpeg \
    unzip \
    openjdk21-jre-headless --repository=https://dl-cdn.alpinelinux.org/alpine/v$(cut -d. -f1,2 /etc/alpine-release)/community/

WORKDIR /jdownloader

COPY docker-entrypoint.sh \
     functions.sh \
     setup.sh \
     org.jdownloader.extensions.eventscripter.EventScripterExtension.json \
     org.jdownloader.extensions.eventscripter.EventScripterExtension.scripts.json \
     ./

RUN chmod 777 \
        . \
        docker-entrypoint.sh \
        functions.sh \
        setup.sh \
        org.jdownloader.extensions.eventscripter.EventScripterExtension.json \
        org.jdownloader.extensions.eventscripter.EventScripterExtension.scripts.json

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
