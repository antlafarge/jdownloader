FROM alpine:3.12

ENV OS="alpine" \
    JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_NAME="jd-$OS" \
    UID="1000" \
    GID="1000"

RUN apk -U upgrade \
    && apk add --no-cache \
        bash \
        curl \
        openjdk8-jre \
        ffmpeg

WORKDIR /jdownloader

COPY run.sh .

CMD ["/bin/bash", "-c", "./run.sh"]
