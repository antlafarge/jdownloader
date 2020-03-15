FROM ubuntu

ENV JD_EMAIL ""

ENV JD_PASSWORD ""

ENV JD_NAME "JDownloader"

ENV UID 1000

ENV GID 1000

RUN apt update

RUN apt install -y wget openjdk-8-jre ffmpeg

WORKDIR /jdownloader

COPY run.sh .

RUN chmod 777 run.sh

CMD ["/bin/bash", "-c", "./run.sh"]
