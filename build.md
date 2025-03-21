# BUILD

## First steps

- Check files use `LF` line endings (linux style).  

## Build docker image

### Ubuntu

    docker build -t ubuntu-openjdk21 -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-21-jre-headless" .

### Alpine

    docker build -t alpine-openjdk21 -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk21-jre-headless" .

### Debian

    docker build -t debian-openjdk17 -f ./Dockerfile/debian.Dockerfile --build-arg OPENJDK="openjdk-17-jre-headless" .

## Build and push for all architectures

https://docs.docker.com/buildx/working-with-buildx  
https://www.docker.com/blog/multi-arch-images  

    docker buildx ls
    docker buildx rm mybuilder
    docker buildx create --name mybuilder
    docker buildx use mybuilder
    docker buildx inspect --bootstrap

### OpenJDK 8

#### dev

    docker buildx build --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk8 -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk8-jre" --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk8 -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-8-jre-headless" --push .

#### release

    docker buildx build --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:alpine-openjdk8 -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk8-jre" --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk8 -t antlafarge/jdownloader:openjdk8 -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-8-jre-headless" --push .

### OpenJDK 17

#### dev

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk17 -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk17-jre-headless" --push .
    docker buildx build --platform linux/386,linux/amd64,linux/arm/v5,linux/arm/v7,linux/arm64/v8,linux/mips64le,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-debian-openjdk17 -f ./Dockerfile/debian.Dockerfile --build-arg OPENJDK="openjdk-17-jre-headless" --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk17 -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-17-jre-headless" --push .

#### release

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:alpine-openjdk17 -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk17-jre-headless" --push .
    docker buildx build --platform linux/386,linux/amd64,linux/arm/v5,linux/arm/v7,linux/arm64/v8,linux/mips64le,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:debian-openjdk17 -f ./Dockerfile/debian.Dockerfile --build-arg OPENJDK="openjdk-17-jre-headless" --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk17 -t antlafarge/jdownloader:openjdk17 -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-17-jre-headless" --push .

### OpenJDK 21

#### dev

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk21 -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk21-jre-headless" --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk21 -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-21-jre-headless" --push .

#### release

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:alpine-openjdk21 -t antlafarge/jdownloader:alpine -f ./Dockerfile/alpine.Dockerfile --build-arg OPENJDK="openjdk21-jre-headless" --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk21 -t antlafarge/jdownloader:openjdk21 -t antlafarge/jdownloader:ubuntu -t antlafarge/jdownloader:latest -f ./Dockerfile/ubuntu.Dockerfile --build-arg OPENJDK="openjdk-21-jre-headless" --push .

## Debug container

    docker exec -it --user root jdownloader /bin/bash
        ps -fp $(pgrep -d" " -u jduser)

    docker commit jdownloader jdebug
    docker run -it --entrypoint=/bin/bash --name jdebug jdebug

## Remove not tagged images

    docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

# Docker commands reminder

## Container stop
```
docker stop jdownloader
```

## Container restart
```
docker restart jdownloader
```

## Container logs
```
docker logs --follow --tail 100 jdownloader
```

*Note: To access the JDownloader log files, you have to set the `<LOGS-PATH>` volume.*

## Container delete
```
docker rm -f jdownloader
```

## Image delete
```
docker rmi antlafarge/jdownloader:openjdk17
```

## Compose start
```
cd /path/to/docker-compose.yml/directory/
docker compose up -d
```

## Compose stop
```
cd /path/to/docker-compose.yml/directory/
docker compose down
```
