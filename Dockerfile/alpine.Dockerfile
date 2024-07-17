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

ARG OPENJDK="openjdk21-jre-headless"

RUN apk update \
 && apk -U upgrade \
 && apk add --no-cache \
        bash \
        curl \
        ffmpeg \
        unzip \
        ${OPENJDK} --repository=https://dl-cdn.alpinelinux.org/alpine/v$(cut -d. -f1,2 /etc/alpine-release)/community/

WORKDIR /jdownloader

COPY src .

RUN chown -R 1000:100 . && chmod 777 . && chmod 775 *.sh && chmod 774 *.json

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
