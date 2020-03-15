# JDownloader

## Run docker container (detached)

### from docker hub

`docker run -d -v <downloadPath>:/downloads/ -e "UID=<uid>" -e "GID=<gid>" -e "JD_EMAIL=<email>" -e "JD_PASSWORD=<password>" --restart unless-stopped --name jdownloader antlafarge/jdownloader:rpi3-raspbian`

- `<downloadPath>` : Absolute download folder path
- `<email>` : Your my.jdownloader.org email
- `<password>` : Your my.jdownloader.org password
- `<uid>` : UID used for downloaded files owner (optional)
- `<gid>` : GID used for downloaded files group owner (optional)

### from locally built image

`docker run -d -v <downloadPath>:/downloads/ -e "UID=<uid>" -e "GID=<gid>" -e "JD_EMAIL=<email>" -e "JD_PASSWORD=<password>" --restart unless-stopped --name jdownloader jdownloader`

#### Build docker image
`docker build -t jdownloader .`

## Display container logs
`docker logs --follow --tail 100 jdownloader`

## Delete container
`docker rm --force jdownloader`
