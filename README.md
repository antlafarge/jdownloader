# JDownloader

## Description

Run JDownloader in headless mode (no graphical interface) in a Docker container.

*Warning : The **alpine** image is smaller, but may lack optimizations. So prefer the default **ubuntu** image (**latest**).*

You can report issues [here (github issues)](https://github.com/antlafarge/jdownloader/issues).

### Setup guide

- Go to [my.jdownloader.org](https://my.jdownloader.org).
- Create an account.
- Copy the **docker run** command and customize the parameters by using your [myJDownloader](https://my.jdownloader.org) credentials.
- Wait some minutes for JDownloader to update and be available in your [myJDownloader web interface](https://my.jdownloader.org).

## Run JDownloader

<pre>
docker run -d --restart unless-stopped &#92;  
    -v <b>&#60;DOWNLOAD-PATH&#62;</b>:/downloads &#92;  
    -e "JD_EMAIL=<b>&#60;JD-EMAIL&#62;</b>" &#92;  
    -e "JD_PASSWORD=<b>&#60;JD-PASSWORD&#62;</b>" &#92;  
        -v <b>&#60;config-path&#62;</b>:/jdownloader/cfg &#92;  
        -v <b>&#60;logs-path&#62;</b>:/jdownloader/logs &#92;  
        -p <b>&#60;port&#62;</b>:3129 &#92;  
        -e "JD_NAME=<b>&#60;jd-name&#62;</b>" &#92;  
        -e "UID=<b>&#60;uid&#62;</b>" &#92;  
        -e "GID=<b>&#60;gid&#62;</b>" &#92;  
    --name <b>&#60;container-name&#62;</b> &#92;  
    antlafarge/jdownloader:<b>&#60;tag&#62;</b>
</pre>

### Mandatory parameters :

- **`<DOWNLOAD-PATH>`** Directory where your downloads will be stored.
- **`<JD-EMAIL>`** Your [myJDownloader](https://my.jdownloader.org) email.
- **`<JD-PASSWORD>`** Your [myJDownloader](https://my.jdownloader.org) password.

### Optional parameters :

- **`<config-path>`** Directory where the JDownloader settings files will be stored.
- **`<logs-path>`** Directory where the JDownloader logs files will be stored.
- **`<port>`** Network port used for Direct connection mode.
- **`<jd-name>`** Device name in your [myJDownloader web interface](https://my.jdownloader.org) (default : `jd-ubuntu` or `jd-alpine`).
- **`<uid>`** Linux User ID used for downloaded files owner (default : `1000`).
- **`<gid>`** Linux Group ID used for downloaded files owner (default : `1000`).
- **`<container-name>`** Docker container name.
- **`<tag>`** Docker hub tag. (if omitted : `latest`).
    - **`latest`** : Linked to `ubuntu` tag.
    - **`ubuntu`** : Use [ubuntu:latest](https://hub.docker.com/_/ubuntu?tab=tags&page=1&ordering=last_updated&name=latest) as base image (more stable).
    - **`alpine`** : Use [alpine:3.12](https://hub.docker.com/_/alpine?tab=tags&page=1&ordering=last_updated&name=3.12) as base image (smaller).

### Minimal example

<pre>
docker run -d --restart unless-stopped \
    -v <b>~/Downloads</b>:/downloads \
    -e "JD_EMAIL=<b>my@email.com</b>" \
    -e "JD_PASSWORD=<b>MyGreatPassword</b>" \
    --name <b>jdownloader</b> \
    antlafarge/jdownloader
</pre>

### Full example

<pre>
docker run -d --restart unless-stopped \
    -v <b>/mnt/hdd/Downloads</b>:/downloads \
    -e "JD_EMAIL=<b>my@email.com</b>" \
    -e "JD_PASSWORD=<b>MyGreatPassword</b>" \
        -v <b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg \
        -v <b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs \
        -p <b>3129</b>:3129 \
        -e "JD_NAME=<b>JD-DOCKER</b>" \
        -e "UID=<b>1000</b>" \
        -e "GID=<b>1000</b>" \
    --name <b>jdownloader</b> \
    antlafarge/jdownloader<b>:ubuntu</b>
</pre>

## Logs

### Container logs

<pre>
docker logs <b>jdownloader</b>
docker logs --follow --tail 100 <b>jdownloader</b>
</pre>

### JDownloader logs

To access the JDownloader logs, you have to set a volume.  
Look at `<logs-path>` in the **docker run** command.

## Delete container and image

<pre>
docker rm -f <b>jdownloader</b>
docker rmi <b>antlafarge/jdownloader</b>
</pre>
