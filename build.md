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

#### dev

    docker buildx build --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk8 -f alpine-openjdk8.Dockerfile --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk8 -f ubuntu-openjdk8.Dockerfile --push .

#### release

    docker buildx build --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:alpine-openjdk8 -f alpine-openjdk8.Dockerfile --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk8 -t antlafarge/jdownloader:openjdk8 -f ubuntu-openjdk8.Dockerfile --push .

### OpenJDK 17

#### dev

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk17 -f alpine-openjdk17.Dockerfile --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk17 -f ubuntu-openjdk17.Dockerfile --push .

#### release

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:alpine-openjdk17 -f alpine-openjdk17.Dockerfile --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk17 -t antlafarge/jdownloader:openjdk17 -f ubuntu-openjdk17.Dockerfile --push .

### OpenJDK 21

#### dev

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:dev-alpine-openjdk21 -f alpine-openjdk21.Dockerfile --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:dev-ubuntu-openjdk21 -f ubuntu-openjdk21.Dockerfile --push .

#### release

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x -t antlafarge/jdownloader:alpine-openjdk21 -t antlafarge/jdownloader:alpine -f alpine-openjdk21.Dockerfile --push .
    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x -t antlafarge/jdownloader:ubuntu-openjdk21 -t antlafarge/jdownloader:openjdk21 -t antlafarge/jdownloader:ubuntu -t antlafarge/jdownloader:latest -f ubuntu-openjdk21.Dockerfile --push .

## Debug container

    docker exec -it --user root jdownloader /bin/bash
        ps -fp $(pgrep -d" " -u jduser)

    docker commit jdownloader jdebug
    docker run -it --entrypoint=/bin/bash --name jdebug jdebug

## Remove not tagged images

    docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
