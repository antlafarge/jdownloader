FROM alpine:3

LABEL dockerhub="https://hub.docker.com/r/antlafarge/jdownloader"
LABEL github="https://github.com/antlafarge/jdownloader"
LABEL maintainer.name="Antoine Lafarge"
LABEL maintainer.email="ant.lafarge@gmail.com"
LABEL maintainer.github="https://github.com/antlafarge"
LABEL maintainer.dockerhub="https://hub.docker.com/u/antlafarge"

ENV JD_EMAIL=""
# check=skip=SecretsUsedInArgOrEnv
ENV JD_PASSWORD=""
ENV JD_DEVICENAME=""
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV LOG_FILE="/dev/null"
ENV JAVA_OPTIONS=""
ENV UMASK=""

ARG OPENJDK="openjdk21-jre-headless"

RUN version=$(cut -d. -f1,2 /etc/alpine-release | tr -d '[:space:]') && \
    apk add --no-cache \
        --repository=https://dl-cdn.alpinelinux.org/alpine/v$version/main \
        --repository=https://dl-cdn.alpinelinux.org/alpine/v$version/community \
        bash \
        curl \
        ffmpeg \
        unzip \
        ${OPENJDK}

RUN mkdir -p -m 777 /app /jdownloader && \
    chown 1000:100 /app /jdownloader

COPY --chown=1000:100 --chmod=777 ./src /app

WORKDIR /app

ENTRYPOINT ["./docker-entrypoint.sh"]
