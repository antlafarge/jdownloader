# BUILD

## First steps

- Check files use `LF` line endings (linux style).  

## Build docker image

### ubuntu

    docker build -t jd-ubuntu -f ubuntu.Dockerfile .

### alpine

    docker build -t jd-alpine -f alpine.Dockerfile .

## Build and push for all architectures

https://docs.docker.com/buildx/working-with-buildx  
https://www.docker.com/blog/multi-arch-images  

    docker buildx ls
    docker buildx rm mybuilder
    docker buildx create --name mybuilder
    docker buildx use mybuilder
    docker buildx inspect --bootstrap

### dev

#### dev-alpine

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:dev-alpine -f alpine.Dockerfile --push .

#### dev-ubuntu

    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:dev-ubuntu -f ubuntu.Dockerfile --push .

### alpine

    docker buildx build --platform linux/amd64,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:1.2-alpine -t antlafarge/jdownloader:alpine -f alpine.Dockerfile --push .

### ubuntu (and latest because more stable)

    docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/s390x -t antlafarge/jdownloader:1.2-ubuntu -t antlafarge/jdownloader:1.2 -t antlafarge/jdownloader:ubuntu -t antlafarge/jdownloader:latest -f ubuntu.Dockerfile --push .

## Debug container

    docker exec -it --user root jdownloader /bin/bash
        ps -fp $(pgrep -d" " -u jduser)

    docker commit jdownloader jdebug
    docker run -it --entrypoint=/bin/bash --name jdebug jdebug

## Remove not tagged images

    docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
