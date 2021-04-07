FROM ubuntu:latest

STOPSIGNAL SIGTERM

ENV OS="ubuntu" \
    JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_NAME="jd-$OS" \
    UID="1000" \
    GID="1000"

RUN apt update \
    && apt install -y --no-install-recommends \
        curl \
        openjdk-8-jre-headless \
        ffmpeg \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /jdownloader

COPY docker-entrypoint.sh \
    functions.sh \
    setup.sh \
    start.sh \
    ./

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
