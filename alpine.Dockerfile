FROM alpine:latest

STOPSIGNAL SIGTERM

ENV JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_NAME="" \
    UID="1000" \
    GID="1000"

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
