FROM ubuntu:latest

ENV OS="ubuntu" \
    JD_EMAIL="" \
    JD_PASSWORD="" \
    JD_NAME="jd-$OS" \
    UID="1000" \
    GID="1000"

RUN apt update \
    && apt install -y \
        curl \
        openjdk-11-jre \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /jdownloader

COPY run.sh .

CMD ["/bin/bash", "-c", "./run.sh"]
