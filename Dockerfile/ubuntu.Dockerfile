FROM ubuntu:latest

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

ARG OPENJDK="openjdk-21-jre-headless"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        bash \
        curl \
        ffmpeg \
        unzip \
        ${OPENJDK} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN mkdir -m 777 /jdownloader/

COPY --chown=1000:100 --chmod=777 ./src/ /jdownloader/

WORKDIR /jdownloader/
 
ENTRYPOINT ["./docker-entrypoint.sh"]
