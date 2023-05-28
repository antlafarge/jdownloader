FROM alpine:latest

LABEL dockerhub="https://hub.docker.com/r/antlafarge/jdownloader"
LABEL github="https://github.com/antlafarge/jdownloader"
LABEL maintainer.name="Antoine Lafarge"
LABEL maintainer.email="ant.lafarge@gmail.com"
LABEL maintainer.github="https://github.com/antlafarge"
LABEL maintainer.dockerhub="https://hub.docker.com/u/antlafarge"

ENV JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_DEVICENAME="" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    LOG_FILE="/dev/null" \
    JAVA_OPTIONS=""

RUN apk -U upgrade \
    && apk add --no-cache \
        bash \
        curl \
        openjdk17-jre-headless \
        ffmpeg \
        unzip \
        jq

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
