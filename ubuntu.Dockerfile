FROM ubuntu:latest

STOPSIGNAL SIGTERM

ENV JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_DEVICENAME="" \
    UID="1000" \
    GID="1000" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

RUN apt update \
    && apt install -y --no-install-recommends \
        curl \
        openjdk-8-jre-headless \
        ffmpeg \
    && apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /jdownloader

COPY docker-entrypoint.sh \
    functions.sh \
    setup.sh \
    ./

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
