# JDownloader

## Run docker container

    docker run -d -v <downloadPath>:/downloads/ -e "JD_EMAIL=<email>" -e "JD_PASSWORD=<password>" --restart unless-stopped --name jdownloader antlafarge/jdownloader

Replace `downloadPath` by your absolute folder path on your local device.

### Available environment variables :

+ Mandatory :
    - `JD_EMAIL` : Your my.jdownloader.org email
    - `JD_PASSWORD` : Your my.jdownloader.org password

+ Optional :
    - `JD_NAME` : Device name in your my.jdownloader.org interface (default : `JDownloader`)
    - `UID` : UID used for downloaded files owner (default : `1000`)
    - `GID` : GID used for downloaded files group owner (default : `1000`)

## Display container logs
    docker logs --follow --tail 100 jdownloader

## Delete container
    docker rm --force jdownloader

## Build docker image
    docker build -t jdownloader .

## Install docker
    sudo curl -sSL https://get.docker.com / | sh
    sudo usermod -aG docker <username>
