# BUILD

## First steps

- Check files use `LF` line endings (linux style).  

## Build docker image

### ubuntu

    docker build -t ubuntu-openjdk17 -f ubuntu-openjdk17.Dockerfile .

### alpine

    docker build -t alpine-openjdk17 -f alpine-openjdk17.Dockerfile .

## Build and push for all architectures

https://docs.docker.com/buildx/working-with-buildx  
https://www.docker.com/blog/multi-arch-images  

    docker buildx ls
    docker buildx rm mybuilder
    docker buildx create --name mybuilder
    docker buildx use mybuilder
    docker buildx inspect --bootstrap

### OpenJDK 8

#### dev-alpine

    docker buildx build --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk8 -f alpine-openjdk8.Dockerfile --push .

#### dev-ubuntu

    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk8 -f ubuntu-openjdk8.Dockerfile --push .

#### alpine

    docker buildx build --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:alpine-openjdk8 -f alpine-openjdk8.Dockerfile --push .

#### ubuntu

    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk8 -t antlafarge/jdownloader:openjdk8 -f ubuntu-openjdk8.Dockerfile --push .

### OpenJDK 17

#### dev-alpine

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk17 -f alpine-openjdk17.Dockerfile --push .

#### dev-ubuntu

    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk17 -f ubuntu-openjdk17.Dockerfile --push .

#### alpine

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:alpine-openjdk17 -t antlafarge/jdownloader:alpine -f alpine-openjdk17.Dockerfile --push .

#### ubuntu (and latest because more stable)

    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk17 -t antlafarge/jdownloader:openjdk17 -t antlafarge/jdownloader:ubuntu -t antlafarge/jdownloader:latest -f ubuntu-openjdk17.Dockerfile --push .

## Debug container

    docker exec -it --user root jdownloader /bin/bash
        ps -fp $(pgrep -d" " -u jduser)

    docker commit jdownloader jdebug
    docker run -it --entrypoint=/bin/bash --name jdebug jdebug

## Remove not tagged images

    docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
