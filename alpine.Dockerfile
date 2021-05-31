FROM alpine:latest

STOPSIGNAL SIGTERM

ENV JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_DEVICENAME="" \
    UID="1000" \
    GID="1000" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

RUN apk -U upgrade \
    && apk add --no-cache \
        bash \
        curl \
        openjdk8-jre \
        ffmpeg

WORKDIR /jdownloader

COPY docker-entrypoint.sh \
    functions.sh \
    setup.sh \
    ./

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
