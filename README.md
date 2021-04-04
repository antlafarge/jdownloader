# JDownloader

## Description

Run JDownloader in headless mode (no graphical interface) in a Docker container.

*Warning : The **alpine** image is smaller, but may lack optimizations. So prefer the default **ubuntu** image (**latest**).*

You can report issues [here (github issues)](https://github.com/antlafarge/jdownloader/issues).

## Docker

<pre>
docker run -d --restart unless-stopped &#92;  
    --name <b>&#60;container-name&#62;</b> &#92;  
    -v "<b>&#60;DOWNLOADS-PATH&#62;</b>:/downloads" &#92;  
    -e "JD_EMAIL=<b>&#60;JD-EMAIL&#62;</b>" &#92;  
    -e "JD_PASSWORD=<b>&#60;JD-PASSWORD&#62;</b>" &#92;  
        -v "<b>&#60;config-path&#62;</b>:/jdownloader/cfg" &#92;  
        -v "<b>&#60;logs-path&#62;</b>:/jdownloader/logs" &#92;  
        -e "JD_NAME=<b>&#60;jd-name&#62;</b>" &#92;  
        -e "UID=<b>&#60;uid&#62;</b>" &#92;  
        -e "GID=<b>&#60;gid&#62;</b>" &#92;  
        -p "<b>&#60;port&#62;</b>:3129" &#92;  
    antlafarge/jdownloader:<b>&#60;tag&#62;</b>
</pre>

*Note : Lowercase parameters are optional.*

### Mandatory parameters :

- **`<DOWNLOADS-PATH>`** Directory where your downloads will be stored.
- **`<JD-EMAIL>`** Your [myJDownloader](https://my.jdownloader.org) email.
- **`<JD-PASSWORD>`** Your [myJDownloader](https://my.jdownloader.org) password.

### Optional parameters :

- **`<container-name>`** Docker container name.
- **`<config-path>`** Directory where the JDownloader settings files will be stored.
- **`<logs-path>`** Directory where the JDownloader logs files will be stored.
- **`<port>`** Network port used for Direct connection mode.
- **`<jd-name>`** Device name in your [myJDownloader web interface](https://my.jdownloader.org) (default : `jd-ubuntu` or `jd-alpine`).
- **`<uid>`** Linux User ID used for downloaded files owner (default : `1000`).
- **`<gid>`** Linux Group ID used for downloaded files owner (default : `1000`).
- **`<tag>`** Docker hub tag. (if omitted : `latest`).
    - **`latest`** : Linked to `ubuntu` tag.
    - **`ubuntu`** : Use [ubuntu:latest](https://hub.docker.com/_/ubuntu?tab=tags&page=1&ordering=last_updated&name=latest) as base image (more stable).
    - **`alpine`** : Use [alpine:3.12](https://hub.docker.com/_/alpine?tab=tags&page=1&ordering=last_updated&name=3.12) as base image (smaller).

### Example

<pre>
docker run -d --restart unless-stopped \
    --name <b>jdownloader</b> \
    -v <b>/mnt/hdd/Downloads</b>:/downloads \
    -e "JD_EMAIL=<b>my@email.fr</b>" \
    -e "JD_PASSWORD=<b>MyGreatPassword</b>" \
        -v <b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg \
        -v <b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs \
        -e "JD_NAME=<b>JD-DOCKER</b>" \
        -e "UID=<b>1000</b>" \
        -e "GID=<b>1000</b>" \
        -p <b>3129</b>:3129 \
    antlafarge/jdownloader
</pre>

*Note : Parameters indented twice are optional.*

## Docker compose

<pre>
services:
  jdownloader:
    image: antlafarge/jdownloader
    container_name: <b>&#60;container-name&#62;</b>
    restart: unless-stopped
    volumes:
      - "<b>&#60;DOWNLOADS-PATH&#62;</b>:/downloads"
      - "<b>&#60;config-path&#62;</b>:/jdownloader/cfg"
      - "<b>&#60;logs-path&#62;</b>:/jdownloader/logs"
    environment:
      - "JD_EMAIL=<b>&#60;JD-EMAIL&#62;</b>"
      - "JD_PASSWORD=<b>&#60;JD-PASSWORD&#62;</b>"
      - "JD_NAME=<b>&#60;jd-name&#62;</b>"
      - "UID=<b>&#60;uid&#62;</b>"
      - "GID=<b>&#60;gid&#62;</b>"
    ports:
      - "<b>&#60;port&#62;</b>:3129"
</pre>

*Note : Lowercase parameters are optional.*

### Example

<pre>
services:
  jdownloader:
    image: antlafarge/jdownloader
    container_name: <b>jdownloader</b>
    restart: unless-stopped
    volumes:
      - "<b>/mnt/hdd/Downloads</b>:/downloads"
      - "<b>/mnt/hdd/Apps/JDownloader/cfg</b>:/jdownloader/cfg"
      - "<b>/mnt/hdd/Apps/JDownloader/logs</b>:/jdownloader/logs"
    environment:
      - "JD_EMAIL=<b>my@email.fr</b>"
      - "JD_PASSWORD=<b>MyGreatPassword</b>"
      - "JD_NAME=<b>JD-DOCKER</b>"
      - "UID=<b>1000</b>"
      - "GID=<b>1000</b>"
    ports:
      - "<b>3129</b>:3129"
</pre>

## Guides

### Setup

- Go to [my.jdownloader.org](https://my.jdownloader.org).
- Create an account.
- Run the container by choosing the **docker run** or **docker-compose** method and customizing the parameters by using your [myJDownloader](https://my.jdownloader.org) credentials.
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
        - Set a `<config-path>` volume to access the JDownloader settings files.
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

*Note: To access the JDownloader logs, you have to set the `<logs-path>` volume.*

### Container delete

<pre>
docker rm -f <b>jdownloader</b>
</pre>

### Image delete

<pre>
docker rmi <b>antlafarge/jdownloader</b>
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
