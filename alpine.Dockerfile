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

RUN addgroup \
    -S -g ${GID} \
    jdgroup && \
  adduser \
    -S -H -D \
    -h /jdownloader \
    -s /bin/bash \
    -u ${UID} \
    -G jdgroup \
    jduser

USER jduser:jdgroup

WORKDIR /jdownloader

COPY --chown=jduser:jdgroup docker-entrypoint.sh \
    functions.sh \
    setup.sh \
    ./

CMD ["/bin/bash", "-c", "./docker-entrypoint.sh"]
