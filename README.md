# JDownloader 2

Docker JDownloader 2 headless image with automatic updates.

There is no embedded graphical interface, you should manage your downloads through the official JDownloader web interface here : [https://my.jdownloader.org](https://my.jdownloader.org).

# Architectures

| arch \ tag | **ubuntu<br>(latest)** | **alpine** |
| :--------: | :--------------------: | :--------: |
| **amd64** | OK | OK |
| **arm64** | OK | OK |
| **arm/v7** | OK | Avoid<br>[Issue 4](https://github.com/antlafarge/jdownloader/issues/4), [Issue 11](https://github.com/antlafarge/jdownloader/issues/11) |
| **arm/v6** | - | [*Need feedback*](https://github.com/antlafarge/jdownloader/discussions) |
| **386** | - | [*Need feedback*](https://github.com/antlafarge/jdownloader/discussions) |
| **ppc64le** | [*Need feedback*](https://github.com/antlafarge/jdownloader/discussions) | [*Need feedback*](https://github.com/antlafarge/jdownloader/discussions) |
| **s390x** | [*Need feedback*](https://github.com/antlafarge/jdownloader/discussions) | [*Need feedback*](https://github.com/antlafarge/jdownloader/discussions) |

You can report issues in the [github issues](https://github.com/antlafarge/jdownloader/issues).  
You can send feedback and discuss the project in the [github discussions](https://github.com/antlafarge/jdownloader/discussions).

# Docker run

[docker run (official documentation)](https://docs.docker.com/engine/reference/run)

<pre>
docker run -d &#92;  
        --name <b>&#60;CONTAINER-NAME&#62;</b> &#92;  
        --restart <b>&#60;RESTART&#62;</b> &#92;  
        --user <b>&#60;UID&#62;:&#60;GID&#62;</b> &#92;  
    -v "<b>&#60;DOWNLOADS-PATH&#62;</b>:/jdownloader/downloads" &#92;  
        -v "<b>&#60;CONFIG-PATH&#62;</b>:/jdownloader/cfg" &#92;  
        -v "<b>&#60;LOGS-PATH&#62;</b>:/jdownloader/logs" &#92;  
    -e "JD_EMAIL=<b>&#60;JD_EMAIL&#62;</b>" &#92;  
    -e "JD_PASSWORD=<b>&#60;JD_PASSWORD&#62;</b>" &#92;  
        -e "JD_DEVICENAME=<b>&#60;JD_DEVICENAME&#62;</b>" &#92;  
        -e "JAVA_OPTIONS=<b>&#60;JAVA_OPTIONS&#62;</b>" &#92;  
        -p "<b>&#60;PORT&#62;</b>:3129" &#92;  
    antlafarge/jdownloader:<b>&#60;TAG&#62;</b>
</pre>

*Note : Parameters indented twice are optional.*

## Parameters

Name | Type | Description | Optional (default)
---- | ---- | ----------- | ------------------
**`<CONTAINER-NAME>`** | [Name](https://docs.docker.com/engine/reference/run/#name---name) | Container name. | Recommended (random)
**`<RESTART>`** | [Restart](https://docs.docker.com/engine/reference/run/#restart-policies---restart) | Container restart policy.<br>*Use `on-failure` to have a correct behavior of `Restart JD`, `Close` and `Shutdown` buttons in the JDownloader settings.<br>Use `unless-stopped` if the container doesn't restart on system reboot.* | Recommended (`no`)
**`<UID>`** | [User](https://docs.docker.com/engine/reference/run/#user) | Owner (User ID) of the files and directories created.<br>*You can use the `id -u` command in your shell to get your current user id.* | Recommended (`0`)
**`<GID>`** | [User](https://docs.docker.com/engine/reference/run/#user) | Owner (Group ID) of the files and directories created.<br>*You can use the `id -g` command in your shell to get your current groud id.* | Recommended (`0`)
**`<DOWNLOADS-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where your downloads will be stored on your host machine.<br>*If you use the `user` parameter, check the permissions of the directories you mount as volumes.* | **REQUIRED**
**`<CONFIG-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where the JDownloader settings files will be stored on your host machine.<br>*If you use the `user` parameter, check the permissions of the directories you mount as volumes.* | Recommended (in container)
**`<LOGS-PATH>`** | [Volume](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) | Directory where the JDownloader log files will be stored on your host machine.<br>*If you use the `user` parameter, check the permissions of the directories you mount as volumes.* | Not recommended (in container)
**`<JD_EMAIL>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Your [myJDownloader](https://my.jdownloader.org) email. | **REQUIRED**
**`<JD_PASSWORD>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Your [myJDownloader](https://my.jdownloader.org) password. | **REQUIRED**
**`<JD_DEVICENAME>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Device name in your [myJDownloader web interface](https://my.jdownloader.org). | Optional (hostname)
**`<JAVA_OPTIONS>`** | [Env](https://docs.docker.com/engine/reference/run/#env-environment-variables) | Java options.<br>*Use `-Xms128m -Xmx1g` to change initial and max Java heap size memory.* | Optional (no options)
**`<PORT>`** | [Port](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) | Network port used for Direct connection mode. | Optional
**`<TAG>`** | [Tag](https://docs.docker.com/engine/reference/run/#imagetag) | Docker hub tag.<br>- `latest` : Same as `ubuntu` tag.<br>- `ubuntu` : Use [ubuntu:latest](https://hub.docker.com/_/ubuntu?tab=tags&page=1&ordering=last_updated&name=latest) as base image (more stable).<br>- `alpine` : Use [alpine:latest](https://hub.docker.com/_/alpine?tab=tags&page=1&ordering=last_updated&name=3.12) as base image (smaller). | Optional (`latest`)

## Example

<pre>
docker run -d \
        --name <b>jdownloader</b> \
        --restart <b>on-failure:10</b> \
        --user <b>1000:100</b> \
    -v <b>/mnt/hdd/JDownloader/downloads</b>:/jdownloader/downloads \
        -v <b>/mnt/hdd/JDownloader/cfg</b>:/jdownloader/cfg \
    -e "JD_EMAIL=<b>my@email.fr</b>" \
    -e "JD_PASSWORD=<b>MyGreatPassword</b>" \
        -e "JD_DEVICENAME=<b>JD-DOCKER</b>" \
        -p <b>3129</b>:3129 \
    antlafarge/jdownloader:<b>latest</b>
</pre>

*Note : Parameters indented twice are optional.*

# Docker Compose

[Docker Compose (official documentation)](https://docs.docker.com/compose)

<pre>
services:
  jdownloader:
    image: antlafarge/jdownloader:<b>&#60;TAG&#62;</b>
    container_name: <b>&#60;CONTAINER-NAME&#62;</b> # optional
    restart: <b>&#60;RESTART&#62;</b> # optional
    user: <b>&#60;UID&#62;:&#60;GID&#62;</b> # optional
    volumes:
      - "<b>&#60;DOWNLOADS-PATH&#62;</b>:/jdownloader/downloads"
      - "<b>&#60;CONFIG-PATH&#62;</b>:/jdownloader/cfg" # optional
      - "<b>&#60;LOGS-PATH&#62;</b>:/jdownloader/logs" # optional
    environment:
      - "JD_EMAIL=<b>&#60;JD_EMAIL&#62;</b>"
      - "JD_PASSWORD=<b>&#60;JD_PASSWORD&#62;</b>"
      - "JD_DEVICENAME=<b>&#60;JD_DEVICENAME&#62;</b>" # optional
      - "JAVA_OPTIONS=<b>&#60;JAVA_OPTIONS&#62;</b>" # optional
    ports:
      - "<b>&#60;PORT&#62;</b>:3129" # optional
</pre>

## Example

<pre>
services:
  jdownloader:
    image: antlafarge/jdownloader<b>:latest</b>
    container_name: <b>jdownloader</b> # optional
    restart: <b>on-failure:10</b> # optional
    user: <b>1000:100</b> # optional
    volumes:
      - "<b>/mnt/hdd/JDownloader/downloads</b>:/jdownloader/downloads"
      - "<b>/mnt/hdd/JDownloader/cfg</b>:/jdownloader/cfg" # optional
    environment:
      - "JD_EMAIL=<b>my@email.fr</b>"
      - "JD_PASSWORD=<b>MyGreatPassword</b>"
      - "JD_DEVICENAME=<b>JD-DOCKER</b>" # optional
    ports:
      - "<b>3129</b>:3129" # optional
</pre>

# Guides

## Setup

- Go to [my.jdownloader.org](https://my.jdownloader.org) and create an account.
- If you want to run the image as an unprivileged user, check the permissions of the directories you mount as volumes, and use the `user` parameter
    - Create the downloads directory : `mkdir /path/to/downloads`
    - Setup the user and group owners : `sudo chown -R 1000:100 /path/to/downloads`
        - You can get your User ID (UID) by using : `id -u`
        - You can get your User Group ID (GID) by using : `id -g`
        - I recommend to use `100` as GID (`users` group), because every users should be in this group, and it will be easier to manage multi-users privileges.
    - Setup the access rights : `sudo chmod -R 770 /path/to/downloads`
    - Do the same for the config directory
- Run the container by choosing the [docker run](https://github.com/antlafarge/jdownloader#docker-run) or [docker compose](https://github.com/antlafarge/jdownloader#docker-compose) method and customize the parameters by using your [myJDownloader](https://my.jdownloader.org) credentials.
    - You can check the container logs : `docker logs --follow --tail 100 jdownloader` (`CTRL + C` to quit)
- Wait some minutes for JDownloader to update and be available in your [myJDownloader web interface](https://my.jdownloader.org).

## Update JDownloader

JDownloader will update itself automatically when it is idle (every 12 hours), so you have nothing to do.  
To disable the automatic upates, go to your JD instance on [my.jdownloader.org](https://my.jdownloader.org), and go to `Settings` / `Event Scripter` and switch from `Enabled` to `Disabled`.

## Update the image

- [Docker run](https://github.com/antlafarge/jdownloader#docker-run) method :
    - Stop the current container : `docker stop jdownloader`
    - Remove the current container : `docker rm jdownloader`
    - Update the image : `docker pull antlafarge/jdownloader:latest`
    - Remove the old untagged images : `docker rmi $(docker images --filter "dangling=true" -q --no-trunc)`
    - Restart the container : `docker start jdownloader`
- [Docker compose](https://github.com/antlafarge/jdownloader#docker-compose) method :
    - Stop the current container : `docker compose stop jdownloader`
    - Remove the current container : `docker compose rm -f jdownloader`
    - Update the image : `docker compose pull jdownloader`
    - Remove the old untagged images : `docker rmi $(docker images --filter "dangling=true" -q --no-trunc)`
    - Restart the container : `docker compose up -d`

## Change your email or password

- If you started the container by setting the email and password environment variables :
  - You must follow the [Update the image](https://github.com/antlafarge/jdownloader#update-the-image) guide by setting the new email or password on the final step.
- If you started the container without setting the email and password environment variables :
    - Run the **setup** script in the running container : `docker exec jdownloader /jdownloader/setup.sh "my@email.fr" "MyNewPassword" "JD-DOCKER"`.
    - Restart the container :
        - [Docker run](https://github.com/antlafarge/jdownloader#docker-run) method : `docker restart jdownloader`.
        - [Docker compose](https://github.com/antlafarge/jdownloader#docker-compose) method : `docker compose restart jdownloader`.

## Special characters in password

If you have special characters in your password, you have 2 solutions :

1. Modify your [docker run](https://github.com/antlafarge/jdownloader#docker-run) command or [docker-compose.yml](https://github.com/antlafarge/jdownloader#docker-compose) file :
    - If you have exclamation marks (`!`) in your password and you use a **bash** shell, this special character correponds to commands history substitution. You might need to disable it by using the command `set +H` in your bash shell.
    - If your password contains double quotes (`"`), escape it with backslashes (`\`) in the [docker run](https://github.com/antlafarge/jdownloader#docker-run) command or [docker-compose.yml](https://github.com/antlafarge/jdownloader#docker-compose) file. ``"JD_PASSWORD=My\"Great`Password"``
        - If you use the [docker run](https://github.com/antlafarge/jdownloader#docker-run) method, also escape backticks (`` ` ``) with backslashes (`\`). ``"JD_PASSWORD=My\"Great\`Password"``
    - Start the container.

2. Or put your password manually in the settings file :
    - Modify your [docker run](https://github.com/antlafarge/jdownloader#docker-run) command or [docker-compose.yml](https://github.com/antlafarge/jdownloader#docker-compose) file parameters :
        - Set an empty `<JD_PASSWORD>` (for disabling password replacement on container start). `"JD_PASSWORD="`
        - Set a `<CONFIG-PATH>` volume to access the JDownloader settings files.
    - Start the container.
    - Go to your config directory and open the settings file named `org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json`.
    - Search for the password field and place your password in the empty double quotes. `"password":"MyGreatPassword",`
    - If your password contains double quotes (`"`), escape it with backslashes (`\`). ``"password":"My\"Great`Password",``
    - Save the file and restart the container. `docker restart jdownloader`

# Troubleshooting

## Files permissions issue

Check your user can read and write the directories you mounted as [volumes](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems).  
Read carefully the [Setup guide](https://github.com/antlafarge/jdownloader#docker-compose) and follow the steps.  
Or run the container as root (remove `user` option).

## Armhf libseccomp2 issue

If you run the image on an armhf host (linux/arm/v7), you may encounter many command errors (`wait`, `sleep`, `curl`, `date`)  
This may be resolved by upgrading the `libseccomp2` library (docker dependency).  
First you should try to upgrade your system by using the usual method.  
If this upgrade didn't resolve the problem, add the backports repo for debian buster and update : 
``` 
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138  
echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list  
sudo apt update  
sudo apt install -t buster-backports libseccomp2
```

## Docker privileges

If nothing worked and many internal commands fail, your container may lack some privileges and you can try the [--privileged](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) flag.

## Nothing worked / another issue

You can report issues in the [github issues](https://github.com/antlafarge/jdownloader/issues).  
You can send feedback and discuss the project in the [github discussions](https://github.com/antlafarge/jdownloader/discussions).

# Docker commands reminder

## Container stop

<pre>
docker stop <b>jdownloader</b>
</pre>

## Container restart

<pre>
docker restart <b>jdownloader</b>
</pre>

## Container logs

<pre>
docker logs --follow --tail 100 <b>jdownloader</b>
</pre>

*Note: To access the JDownloader log files, you have to set the `<LOGS-PATH>` volume.*

## Container delete

<pre>
docker rm -f <b>jdownloader</b>
</pre>

## Image delete

<pre>
docker rmi antlafarge/jdownloader:<b>latest</b>
</pre>

## Compose start

<pre>
cd /path/to/docker-compose.yml/directory/
docker compose up -d
</pre>

## Compose stop

<pre>
cd /path/to/docker-compose.yml/directory/
docker compose down
</pre>
