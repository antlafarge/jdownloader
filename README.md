# JDownloader

## Description

Run JDownloader in headless mode (no graphical interface) in a Docker container.

## Architectures

|     | amd64| arm64 | arm/v7 | arm/v6 | 386 | ppc64le | s390x |
| :-: | :--: | :---: | :----: | :----: | :-: | :-----: | :---: |
| **Ubuntu<br>(latest)** | OK<br>tested by<br>[antlafarge](https://github.com/antlafarge) | - | OK<br>tested by<br>[antlafarge](https://github.com/antlafarge) | - | - | - | - |
| **Alpine** | OK<br>tested by<br>[antlafarge](https://github.com/antlafarge) | - | Performance issues<br>*bad openJDK optimization*<br>Use ubuntu | - | - | - | - |

You can send feedback and report issues on architectures you tested [here (github issues)](https://github.com/antlafarge/jdownloader/issues).

## Docker

<pre>
docker run -d &#92;  
        --name <b>&#60;CONTAINER-NAME&#62;</b> &#92;  
        --restart <b>&#60;RESTART&#62;</b> &#92;  
    -v "<b>&#60;DOWNLOADS-PATH&#62;</b>:/jdownloader/downloads" &#92;  
        -v "<b>&#60;CONFIG-PATH&#62;</b>:/jdownloader/cfg" &#92;  
        -v "<b>&#60;LOGS-PATH&#62;</b>:/jdownloader/logs" &#92;  
    -e "JD_EMAIL=<b>&#60;JD-EMAIL&#62;</b>" &#92;  
    -e "JD_PASSWORD=<b>&#60;JD-PASSWORD&#62;</b>" &#92;  
        -e "JD_NAME=<b>&#60;JD-NAME&#62;</b>" &#92;  
        -e "UID=<b>&#60;UID&#62;</b>" &#92;  
        -e "GID=<b>&#60;GID&#62;</b>" &#92;  
        -p "<b>&#60;PORT&#62;</b>:3129" &#92;  
    antlafarge/jdownloader:<b>&#60;TAG&#62;</b>
</pre>

*Note : Parameters indented twice are optional.*

### Parameters :

Name | Type | Description | Optional (default)
---- | ---- | ----------- | ------------------
**`<CONTAINER-NAME>`** | [Name](https://docs.docker.com/engine/reference/run/#name---name) | Docker container name. | Optional<br>(random)
**`<RESTART>`** | [Restart](https://docs.docker.com/engine/reference/run/#restart-policies---restart) | Docker container restart policy.<br>*Use `on-failure` to have a correct behavior of `Restart JD`, `Close` and `Shutdown` buttons in the JDownloader settings.* | Optional<br>(`no`)
**`<DOWNLOADS-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where your downloads will be stored on your host machine. | REQUIRED
**`<CONFIG-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where the JDownloader settings files will be stored on your host machine. | Optional (in container)
**`<LOGS-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where the JDownloader logs files will be stored on your host machine. | Optional (in container)
**`<JD-EMAIL>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Your [myJDownloader](https://my.jdownloader.org) email. | REQUIRED
**`<JD-PASSWORD>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Your [myJDownloader](https://my.jdownloader.org) password. | REQUIRED
**`<JD-NAME>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Device name in your [myJDownloader web interface](https://my.jdownloader.org). | Optional<br>(`jd-ubuntu` or `jd-alpine`)
**`<UID>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Owner (User ID) of the files and directories created. | Optional<br>(`1000`)
**`<GID>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Owner (Group ID) of the files and directories created. | Optional<br>(`1000`)
**`<PORT>`** | [Port](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) | Network port used for Direct connection mode. | Optional
**`<TAG>`** | [Tag](https://docs.docker.com/engine/reference/run/#imagetag) | Docker hub tag.<br>- **`latest`** : Linked to `ubuntu` tag.<br>- **`ubuntu`** : Use [ubuntu:latest](https://hub.docker.com/_/ubuntu?tab=tags&page=1&ordering=last_updated&name=latest) as base image (more stable).<br>- **`alpine`** : Use [alpine:3.12](https://hub.docker.com/_/alpine?tab=tags&page=1&ordering=last_updated&name=3.12) as base image (smaller). | Optional<br>(`latest`)

### Example

<pre>
docker run -d \
        --name <b>jdownloader</b> \
        --restart <b>on-failure:2</b> \
    -v <b>/mnt/hdd/Apps/JDownloader/Downloads</b>:/jdownloader/downloads \
        -v <b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg \
        -v <b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs \
    -e "JD_EMAIL=<b>my@email.fr</b>" \
    -e "JD_PASSWORD=<b>MyGreatPassword</b>" \
        -e "JD_NAME=<b>jd-docker</b>" \
        -e "UID=<b>1000</b>" \
        -e "gid=<b>1000</b>" \
        -p <b>3129</b>:3129 \
    antlafarge/jdownloader:<b>latest</b>
</pre>

*Note : Parameters indented twice are optional.*

## Docker compose

<pre>
services:
  jdownloader:
    image: antlafarge/jdownloader:<b>&#60;TAG&#62;</b>
    container_name: <b>&#60;CONTAINER-NAME&#62;</b> # optional
    restart: <b>&#60;RESTART&#62;</b> # optional
    volumes:
      - "<b>&#60;DOWNLOADS-PATH&#62;</b>:/jdownloader/downloads"
      - "<b>&#60;CONFIG-PATH&#62;</b>:/jdownloader/cfg" # optional
      - "<b>&#60;LOGS-PATH&#62;</b>:/jdownloader/logs" # optional
    environment:
      - "JD_EMAIL=<b>&#60;JD-EMAIL&#62;</b>"
      - "JD_PASSWORD=<b>&#60;JD-PASSWORD&#62;</b>"
      - "JD_NAME=<b>&#60;JD-NAME&#62;</b>" # optional
      - "UID=<b>&#60;UID&#62;</b>" # optional
      - "GID=<b>&#60;GID&#62;</b>" # optional
    ports:
      - "<b>&#60;PORT&#62;</b>:3129" # optional
</pre>

### Example

<pre>
services:
  jdownloader:
    image: antlafarge/jdownloader<b>:latest</b>
    container_name: <b>jdownloader</b> # optional
    restart: <b>on-failure:2</b> # optional
    volumes:
      - "<b>/mnt/hdd/Apps/JDownloader/Downloads</b>:/jdownloader/downloads"
      - "<b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg" # optional
      - "<b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs" # optional
    environment:
      - "JD_EMAIL=<b>my@email.fr</b>"
      - "JD_PASSWORD=<b>MyGreatPassword</b>"
      - "JD_NAME=<b>jd-docker</b>" # optional
      - "UID=<b>1000</b>" # optional
      - "GID=<b>1000</b>" # optional
    ports:
      - "<b>3129</b>:3129" # optional
</pre>

## Guides

### Setup

- Go to [my.jdownloader.org](https://my.jdownloader.org).
- Create an account.
- Run the container by choosing the [docker run](https://docs.docker.com/engine/reference/run) or [docker-compose](https://docs.docker.com/compose) method and customizing the parameters by using your [myJDownloader](https://my.jdownloader.org) credentials.
- Wait some minutes for JDownloader to update and be available in your [myJDownloader web interface](https://my.jdownloader.org).

### Special characters in password

If you have special characters in your password, you have 2 solutions :

1. Adapt your **docker run** command or **docker-compose.yml** file :
    - If you have exclamation marks (`!`) in your password and you use a **bash** shell, this special character correponds to commands history substitution. You might need to disable it by typing the command `set +H` in your bash shell.
    - If your password contains double quotes (`"`) or backticks (`` ` ``), escape it with backslashes (`\`) in the **docker run** command or **docker-compose.yml** file. ``"JD_PASSWORD=My\"Great\`Password"``
    - Start the docker container.

2. Or put your password manually in the settings file :
    - Customize your **docker run** command or **docker-compose.yml** file parameters :
        - Set an empty `<JD-PASSWORD>` (because the password will be replaced each time the container is restarted). `"JD_PASSWORD="`
        - Set a `<CONFIG-PATH>` volume to access the JDownloader settings files.
    - Start the docker container.
    - Go to your config directory and open the settings file named `org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json`.
    - Search for the password field and place your password in the empty double quotes. `"password":"MyGreatPassword",`
    - If your password contains double quotes (`"`), escape it with backslashes (`\`). `"password":"My\"Great\"Password",`
    - Save the file and restart the container. `docker restart jdownloader`

## Docker commands reminder

### Container stop

<pre>
docker stop <b>jdownloader</b>
</pre>

### Container restart

<pre>
docker restart <b>jdownloader</b>
</pre>

### Container logs

<pre>
docker logs --follow --tail 100 <b>jdownloader</b>
</pre>

*Note: To access the JDownloader logs, you have to set the `<LOGS-PATH>` volume.*

### Container delete

<pre>
docker rm -f <b>jdownloader</b>
</pre>

### Image delete

<pre>
docker rmi antlafarge/jdownloader:<b>latest</b>
</pre>

### Compose start

<pre>
cd /path/to/docker-compose.yml/directory/
docker-compose up -d
</pre>

### Compose stop

<pre>
cd /path/to/docker-compose.yml/directory/
docker-compose down
</pre>
