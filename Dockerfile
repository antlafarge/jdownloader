FROM ubuntu

RUN apt update

RUN apt install -y wget openjdk-8-jre ffmpeg

WORKDIR /jdownloader

COPY run.sh .

RUN chmod 777 run.sh

ENV UID 1000

ENV GID 1000

ENV JD_EMAIL ""

ENV JD_PASSWORD ""

CMD ["/bin/bash", "-c", "./run.sh"]
