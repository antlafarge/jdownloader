# JDownloader

## Description

Run JDownloader in headless mode (no graphical interface) in a Docker container.

## Architectures

|     | **Ubuntu<br>(latest)** | **Alpine** |
| :-: | :--------------------: | :--------: |
| **amd64** | [i7 / Windows 10](https://github.com/antlafarge/jdownloader/issues/6) : OK | [i7 / Windows 10](https://github.com/antlafarge/jdownloader/issues/5) : OK |
| **arm64** | [Raspberry PI 4B / Raspberry OS](https://github.com/antlafarge/jdownloader/issues/1) : OK<br>[Raspberry PI 3B+ / Raspberry OS](https://github.com/antlafarge/jdownloader/issues/9) : OK | [Raspberry PI 4B / Raspberry OS](https://github.com/antlafarge/jdownloader/issues/8) : OK<br>[Raspberry PI 3B+ / Raspberry OS](https://github.com/antlafarge/jdownloader/issues/10) : OK |
| **arm/v7** | [Raspberry PI 3B+ / Raspberry OS](https://github.com/antlafarge/jdownloader/issues/3) : OK<br>[Odroid HC1 / Armbian](https://github.com/antlafarge/jdownloader/issues/2) : OK | [Raspberry PI 3B+ / Raspberry OS](https://github.com/antlafarge/jdownloader/issues/4) : Avoid<br>[Odroid HC1 / Armbian](https://github.com/antlafarge/jdownloader/issues/11) : Avoid |
| **arm/v6** | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) |
| **386** | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) |
| **ppc64le** | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) |
| **s390x** | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) | [*Need feedback*](https://github.com/antlafarge/jdownloader/issues) |

### Troubleshooting

For many reasons, docker can be instable depending on builds, devices, architectures, OS, packages, etc...  
If you encounter some difficulties to run the image, you can try the [--privileged](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) flag.  
You can send feedback and report problems in the [github issues](https://github.com/antlafarge/jdownloader/issues).

## Docker CLI

<pre>
docker run -d &#92;  
        --name <b>&#60;CONTAINER-NAME&#62;</b> &#92;  
        --restart <b>&#60;RESTART&#62;</b> &#92;  
    -v "<b>&#60;DOWNLOADS-PATH&#62;</b>:/jdownloader/downloads" &#92;  
        -v "<b>&#60;CONFIG-PATH&#62;</b>:/jdownloader/cfg" &#92;  
        -v "<b>&#60;LOGS-PATH&#62;</b>:/jdownloader/logs" &#92;  
    -e "JD_EMAIL=<b>&#60;JD-EMAIL&#62;</b>" &#92;  
    -e "JD_PASSWORD=<b>&#60;JD-PASSWORD&#62;</b>" &#92;  
        -e "JD_DEVICENAME=<b>&#60;JD-DEVICENAME&#62;</b>" &#92;  
        -e "UID=<b>&#60;UID&#62;</b>" &#92;  
        -e "GID=<b>&#60;GID&#62;</b>" &#92;  
        -p "<b>&#60;PORT&#62;</b>:3129" &#92;  
    antlafarge/jdownloader:<b>&#60;TAG&#62;</b>
</pre>

*Note : Parameters indented twice are optional.*

### Parameters

Name | Type | Description | Optional (default)
---- | ---- | ----------- | ------------------
**`<CONTAINER-NAME>`** | [Name](https://docs.docker.com/engine/reference/run/#name---name) | Container name. | Optional<br>(random)
**`<RESTART>`** | [Restart](https://docs.docker.com/engine/reference/run/#restart-policies---restart) | Container restart policy.<br>*Use `on-failure` to have a correct behavior of `Restart JD`, `Close` and `Shutdown` buttons in the JDownloader settings.* | Optional<br>(`no`)
**`<DOWNLOADS-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where your downloads will be stored on your host machine. | REQUIRED
**`<CONFIG-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where the JDownloader settings files will be stored on your host machine. | Optional (in container)
**`<LOGS-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where the JDownloader logs files will be stored on your host machine. | Optional (in container)
**`<JD-EMAIL>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Your [myJDownloader](https://my.jdownloader.org) email. | REQUIRED
**`<JD-PASSWORD>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Your [myJDownloader](https://my.jdownloader.org) password. | REQUIRED
**`<JD-DEVICENAME>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Device name in your [myJDownloader web interface](https://my.jdownloader.org). | Optional<br>(hostname)
**`<UID>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Owner (User ID) of the files and directories created. | Optional<br>(`1000`)
**`<GID>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Owner (Group ID) of the files and directories created. | Optional<br>(`1000`)
**`<PORT>`** | [Port](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) | Network port used for Direct connection mode. | Optional
**`<TAG>`** | [Tag](https://docs.docker.com/engine/reference/run/#imagetag) | Docker hub tag.<br>- `latest` : Linked to `ubuntu` tag.<br>- `ubuntu` : Use [ubuntu:latest](https://hub.docker.com/_/ubuntu?tab=tags&page=1&ordering=last_updated&name=latest) as base image (more stable).<br>- `alpine` : Use [alpine:latest](https://hub.docker.com/_/alpine?tab=tags&page=1&ordering=last_updated&name=3.12) as base image (smaller). | Optional<br>(`latest`)

### Example

<pre>
docker run -d \
        --name <b>jdownloader</b> \
        --restart <b>on-failure:2</b> \
    -v <b>/mnt/hdd/Apps/JDownloader/downloads</b>:/jdownloader/downloads \
        -v <b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg \
        -v <b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs \
    -e "JD_EMAIL=<b>my@email.fr</b>" \
    -e "JD_PASSWORD=<b>MyGreatPassword</b>" \
        -e "JD_DEVICENAME=<b>JD-DOCKER</b>" \
        -e "UID=<b>1000</b>" \
        -e "GID=<b>1000</b>" \
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
      - "JD_DEVICENAME=<b>&#60;JD-DEVICENAME&#62;</b>" # optional
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
      - "<b>/mnt/hdd/Apps/JDownloader/downloads</b>:/jdownloader/downloads"
      - "<b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg" # optional
      - "<b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs" # optional
    environment:
      - "JD_EMAIL=<b>my@email.fr</b>"
      - "JD_PASSWORD=<b>MyGreatPassword</b>"
      - "JD_DEVICENAME=<b>JD-DOCKER</b>" # optional
      - "UID=<b>1000</b>" # optional
      - "GID=<b>1000</b>" # optional
    ports:
      - "<b>3129</b>:3129" # optional
</pre>

## Guides

### Setup

- Go to [my.jdownloader.org](https://my.jdownloader.org).
- Create an account.
- Run the container by choosing the [docker CLI](https://docs.docker.com/engine/reference/run) or [docker-compose](https://docs.docker.com/compose) method and customizing the parameters by using your [myJDownloader](https://my.jdownloader.org) credentials.
- Wait some minutes for JDownloader to update and be available in your [myJDownloader web interface](https://my.jdownloader.org).

### Update the image

- Remove the current container : `docker rm -f jdownloader`.
- Update the image : `docker pull antlafarge/jdownloader:latest`.
- Remove the old untagged images : `docker rmi $(docker images --filter “dangling=true” -q --no-trunc)`.
- Start a new container by using docker CLI or docker compose.

### Change your email or password

- If you started the container by setting the email and password environment variables :
  - You must follow the [Update the image](https://github.com/antlafarge/jdownloader#update-the-image) guide by setting the new email or password on the final step.
- If you started the container without setting the email and password environment variables :
    - Run the **setup** script in the running container : `docker exec jdownloader /jdownloader/setup.sh "<JD-EMAIL>" "<JD-PASSWORD>" "<JD-DEVICENAME>"`.
    - Restart the container : `docker restart jdownloader`.

### Special characters in password

If you have special characters in your password, you have 2 solutions :

1. Adapt your **docker CLI** command or **docker-compose.yml** file :
    - If you have exclamation marks (`!`) in your password and you use a **bash** shell, this special character correponds to commands history substitution. You might need to disable it by typing the command `set +H` in your bash shell.
    - If your password contains double quotes (`"`) or backticks (`` ` ``), escape it with backslashes (`\`) in the **docker CLI** command or **docker-compose.yml** file. ``"JD_PASSWORD=My\"Great\`Password"``
    - Start the container.

2. Or put your password manually in the settings file :
    - Customize your **docker CLI** command or **docker-compose.yml** file parameters :
        - Set an empty `<JD-PASSWORD>` (for disabling password replacement on container start). `"JD_PASSWORD="`
        - Set a `<CONFIG-PATH>` volume to access the JDownloader settings files.
    - Start the container.
    - Go to your config directory and open the settings file named `org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json`.
    - Search for the password field and place your password in the empty double quotes. `"password":"MyGreatPassword",`
    - If your password contains double quotes (`"`), escape it with backslashes (`\`). ``"password":"My\"Great\`Password",``
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
