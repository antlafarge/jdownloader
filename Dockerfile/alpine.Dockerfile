FROM alpine:latest

LABEL dockerhub="https://hub.docker.com/r/antlafarge/jdownloader"
LABEL github="https://github.com/antlafarge/jdownloader"
LABEL maintainer.name="Antoine Lafarge"
LABEL maintainer.email="ant.lafarge@gmail.com"
LABEL maintainer.github="https://github.com/antlafarge"
LABEL maintainer.dockerhub="https://hub.docker.com/u/antlafarge"

ENV JD_EMAIL=""
ENV JD_PASSWORD=""
ENV JD_DEVICENAME=""
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV LOG_FILE="/dev/null"
ENV JAVA_OPTIONS=""
ENV UMASK=""

ARG OPENJDK="openjdk21-jre-headless"

RUN apk add --no-cache --no-install-recommends \
        --repository=https://dl-cdn.alpinelinux.org/alpine/v$(cut -d. -f1,2 /etc/alpine-release)/community/ \
        bash \
        curl \
        ffmpeg \
        unzip \
        ${OPENJDK}

RUN mkdir -p -m 777 /jdownloader/ && chown 1000:100 /jdownloader/

COPY --chown=1000:100 --chmod=777 ./src/ /jdownloader/

WORKDIR /jdownloader/

ENTRYPOINT ["./docker-entrypoint.sh"]
