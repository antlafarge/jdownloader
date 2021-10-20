FROM ubuntu:latest

STOPSIGNAL SIGTERM

ENV JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_DEVICENAME="" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        openjdk-8-jre-headless \
        ffmpeg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /jdownloader

COPY docker-entrypoint.sh \
    functions.sh \
    setup.sh \
    ./

RUN chmod 777 \
    . \
    docker-entrypoint.sh \
    functions.sh \
    setup.sh

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
