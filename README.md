# JDownloader 2

Docker JDownloader 2 headless image with automatic updates.

There is no embedded graphical interface, you should manage your downloads through the official JDownloader web interface here : [https://my.jdownloader.org](https://my.jdownloader.org).

Dockerhub repository : [https://hub.docker.com/r/antlafarge/jdownloader](https://hub.docker.com/r/antlafarge/jdownloader).  
Github repository : [https://github.com/antlafarge/jdownloader](https://github.com/antlafarge/jdownloader).  
You can report issues in the [github issues](https://github.com/antlafarge/jdownloader/issues).  
You can send feedback and discuss the project in the [github discussions](https://github.com/antlafarge/jdownloader/discussions).

# Supported architectures and Tags

| arch \ tags | [`latest`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=latest)<br>[`ubuntu`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=ubuntu)<br>[`ubuntu-openjdk21`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=ubuntu-openjdk21)<br>[`openjdk21`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=openjdk21) | [`debian`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=debian)<br>[`debian-openjdk21`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=debian-openjdk21)<br> | [`alpine`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=alpine)<br>[`alpine-openjdk21`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=alpine-openjdk21) |
| :- | :---: | :---: | :---: |
| **linux/386** | · | ✓ | · |
| **linux/amd64** | ✓ | ✓ | ✓ |
| **linux/arm/v5** | · | ✓ | · |
| **linux/arm/v6** | | Use [`alpine-openjdk8`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=alpine-openjdk8) | |
| **linux/arm/v7** | ✓ | ✓ | · |
| **linux/arm64/v8** | ✓ | ✓ | ✓ |
| **linux/mips64le** | · | ✓ | · |
| **linux/ppc64le** | ✓ | ✓ | ✓ |
| **linux/riscv64** | ✓ | ✓ | ✓ |
| **linux/s390x** | ✓ | ✓ | ✓ |

### Other available tags :

- [`openjdk17`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=openjdk17) [`ubuntu-openjdk17`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=ubuntu-openjdk17)
- [`debian-openjdk17`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=debian-openjdk17)
- [`alpine-openjdk17`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=alpine-openjdk17)
- [`openjdk8`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=openjdk8) [`ubuntu-openjdk8`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=ubuntu-openjdk8)
- [`alpine-openjdk8`](https://hub.docker.com/repository/docker/antlafarge/jdownloader/tags?page=1&ordering=last_updated&name=alpine-openjdk8)

# [Docker Compose](https://docs.docker.com/compose)

```yml
services:
  jdownloader:
    image: antlafarge/jdownloader:<TAG>
    container_name: <CONTAINER-NAME> # Optional
    restart: <RESTART> # Optional
    user: <UID>:<GID> # Optional
    volumes:
      - "<DOWNLOADS-PATH>:/jdownloader/downloads/"
      - "<CONFIG-PATH>:/jdownloader/cfg/" # Optional
      - "<LOGS-PATH>:/jdownloader/logs/" # Optional
    environment:
      JD_EMAIL: "<JD-EMAIL>" # Optional (better to use secrets)
      JD_PASSWORD: "<JD-PASSWORD>" # Optional (better to use secrets)
      JD_DEVICENAME: "<JD-DEVICENAME>" # Optional
      UMASK: "<UMASK>" # Optional
      JAVA_OPTIONS: "<JAVA-OPTIONS>" # Optional
      LOG_FILE: "<LOG-FILE>" # Optional
    secrets:
        - JD_EMAIL
        - JD_PASSWORD
        - JD_DEVICENAME # Optional
    ports:
      - <PORT>:3129 # Optional

secrets:
    JD_EMAIL:
        file: "<JD-EMAIL-FILE>" # Put your myJD email in this file
    JD_PASSWORD:
        file: "<JD-PASSWORD-FILE>" # Put your myJD password in this file
    JD_DEVICENAME: # Optional
        file: "<JD-DEVICENAME-FILE>" # Put your myJD device name in this file
```

<details>
<summary>See example</summary>

```yml
services:
  jdownloader:
    image: antlafarge/jdownloader:latest
    container_name: jdownloader
    restart: on-failure:3
    user: 1000:100
    volumes:
      - "/hdd/JDownloader/downloads/:/jdownloader/downloads/"
      - "/hdd/JDownloader/cfg/:/jdownloader/cfg/"
    secrets:
        - JD_EMAIL
        - JD_PASSWORD
        - JD_DEVICENAME
    ports:
      - 3129:3129

secrets:
    JD_EMAIL:
        file: "/hdd/JDownloader/secrets/JD_EMAIL.txt"
    JD_PASSWORD:
        file: "/hdd/JDownloader/secrets/JD_PASSWORD.txt"
    JD_DEVICENAME:
        file: "/hdd/JDownloader/secrets/JD_DEVICENAME.txt"
```
</details>

## Parameters

Name | Type | Description | Optional | Default
---- | ---- | ----------- | -------- | -------
**`<TAG>`** | [Tag](https://docs.docker.com/engine/reference/run/#image-references) | Docker hub tag. | Optional | `latest`
**`<CONTAINER-NAME>`** | [Name](https://docs.docker.com/reference/cli/docker/container/run/#name) | Container name. | Recommended | Random
**`<RESTART>`** | [Restart](https://docs.docker.com/reference/cli/docker/container/run/#restart) | Container restart policy.<br>*Use `on-failure` to have a correct behavior of `Restart`, `Close` and `Shutdown` buttons in the JDownloader settings.* | Recommended | `no`
**`<UID>`** | [User](https://docs.docker.com/engine/reference/run/#user) | Owner user ID of the files and directories created.<br>*Use the command `id -u` in your shell to get your current user id.* | Recommended | `0` (root)
**`<GID>`** | [User](https://docs.docker.com/engine/reference/run/#user) | Owner group ID of the files and directories created.<br>*Use the command `id -g` in your shell to get your current groud id.* | Recommended | `0` (root)
**`<DOWNLOADS-PATH>`** | [Volume](https://docs.docker.com/reference/cli/docker/container/run/#volume) | Directory where your downloads will be stored on your host machine.<br>*If you use the `user` parameter, check the permissions of the directories you mount as volumes.* | **REQUIRED** |
**`<CONFIG-PATH>`** | [Volume](https://docs.docker.com/reference/cli/docker/container/run/#volume) | Directory where the JDownloader settings files will be stored on your host machine.<br>*If you use the `user` parameter, check the permissions of the directories you mount as volumes.* | Recommended | In container
**`<LOGS-PATH>`** | [Volume](https://docs.docker.com/reference/cli/docker/container/run/#volume) | Directory where the JDownloader log files will be stored on your host machine.<br>*If you use the `user` parameter, check the permissions of the directories you mount as volumes.* | Not recommended | In container
**`<JD-EMAIL-FILE>`** | [Secret](https://docs.docker.com/compose/use-secrets/) | The path to the docker secret file where your [myJDownloader](https://my.jdownloader.org) e-mail is saved. | **REQUIRED** |
**`<JD-PASSWORD-FILE>`** | [Secret](https://docs.docker.com/compose/use-secrets/) | The path to the docker secret file where your [myJDownloader](https://my.jdownloader.org) password is saved. | **REQUIRED** |
**`<JD-DEVICENAME-FILE>`** | [Secret](https://docs.docker.com/compose/use-secrets/) | The path to the docker secret file where your [myJDownloader](https://my.jdownloader.org) device name is saved. | Optional | (hostname)
**`<JAVA-OPTIONS>`** | [Env](https://docs.docker.com/reference/cli/docker/container/run/#env) | Java options.<br>*Use `-Xms128m -Xmx1g` to change initial and max Java heap size memory.* | Optional | Empty
**`<UMASK>`** | [Env](https://docs.docker.com/reference/cli/docker/container/run/#env) | Change the *umask*. | Optional | No change
**`<JD-DEVICENAME>`** | [Env](https://docs.docker.com/reference/cli/docker/container/run/#env) | Device name in your [myJDownloader web interface](https://my.jdownloader.org). | Optional | Hostname
**`<JD-EMAIL>`** | [Env](https://docs.docker.com/reference/cli/docker/container/run/#env) | Your [myJDownloader](https://my.jdownloader.org) e-mail.<br>I recommend to use the docker secrets (cf. `<JD-EMAIL-FILE>`). | Not recommended |
**`<JD-PASSWORD>`** | [Env](https://docs.docker.com/reference/cli/docker/container/run/#env) | Your [myJDownloader](https://my.jdownloader.org) password.<br>I recommend to use the docker secrets (cf. `<JD-PASSWORD-FILE>`). | Not recommended |
**`<LOG-FILE>`** | [Env](https://docs.docker.com/reference/cli/docker/container/run/#env) | Write JDownloader logs from `java` command in a file.<br>You should use the volume parameter **`<LOGS-PATH>`** to access these log files from the host machine.<br>Useful if you want to investigate any issues with JDownloader.<br>Example : `"/jdownloader/logs/jd.docker.log"`. | Not recommended | `/dev/null`
**`<PORT>`** | [Port](https://docs.docker.com/reference/cli/docker/container/run/#publish) | Network port used for Direct connection mode. | Optional | Not exposed

# [Docker run](https://docs.docker.com/engine/reference/run)

<details>
<summary>See Docker run</summary>=

```yml
docker run -d \
        --name <CONTAINER-NAME> \
        --restart <RESTART> \
        --user <UID>:<GID> \
    -v "<DOWNLOADS-PATH>:/jdownloader/downloads/" \
        -v "<CONFIG-PATH>:/jdownloader/cfg/" \
        -v "<LOGS-PATH>:/jdownloader/logs/" \
    -v "<JD-EMAIL-FILE>:/run/secrets/JD_EMAIL" \
    -v "<JD-PASSWORD-FILE>:/run/secrets/JD_PASSWORD" \
        -e JD_EMAIL="<JD-EMAIL>" \
        -e JD_PASSWORD="<JD-PASSWORD>" \
        -e JD_DEVICENAME="<JD-DEVICENAME>" \
        -e JAVA_OPTIONS="<JAVA-OPTIONS>" \
        -e LOG_FILE="<LOG-FILE>" \
        -e UMASK="<UMASK>" \
        -p <PORT>:3129 \
    antlafarge/jdownloader:<TAG>
```

*Note : Parameters indented twice are optional.*  
*Volumes are used to simulate secrets without the need to create docker swarm secrets.*

Example :
```yml
echo "my@email.com" > ./JD_EMAIL.txt
echo "MyPassword" > ./JD_PASSWORD.txt

docker run -d \
        --name jdownloader \
        --restart on-failure:3 \
        --user 1000:100 \
    -v "/hdd/JDownloader/downloads/:/jdownloader/downloads/" \
        -v "/hdd/JDownloader/cfg/:/jdownloader/cfg/" \
    -v "./JD_EMAIL.txt:/run/secrets/JD_EMAIL" \
    -v "./JD_PASSWORD.txt:/run/secrets/JD_PASSWORD" \
        -e JD_DEVICENAME="JD-DOCKER" \
        -p 3129:3129 \
    antlafarge/jdownloader:latest
```
</details>

# Guides

## Setup

- Go to [my.jdownloader.org](https://my.jdownloader.org) and create an account.
- If you want to run the container as an unprivileged user, use the `user` parameter and check the access permissions of the directories you mount as volumes
    - Create the downloads directory : `mkdir /path/to/jdownloader/downloads/`
    - Setup the user and group owners : `sudo chown -R 1000:100 /path/to/jdownloader/downloads/`
        - You can get your User ID (UID) by using : `id -u`
        - You can get your User Group ID (GID) by using : `id -g`
            - I recommend to use `100` as GID (`users` group), because every users should be in this group, and it will be easier to manage multi-users privileges.
    - Setup the downloads directory access permissions : `sudo chmod -R 770 /path/to/jdownloader/downloads/`
    - Setup the config directory access permissions : `sudo chmod -R 770 /path/to/jdownloader/cfg/`
    - Setup the secrets directory access permissions : `sudo chmod -R 770 /path/to/jdownloader/secrets/`
        - Create the secret file for your JD e-mail : `echo 'my@email.com' > /path/to/jdownloader/secrets/JD_EMAIL.txt`
        - Create the secret file for your JD password : `echo 'MyGreatPassword' > /path/to/jdownloader/secrets/JD_PASSWORD.txt`
        - Create the secret file for your JD device name : `echo 'JD-DOCKER' > /path/to/jdownloader/secrets/JD_DEVICENAME.txt`
- Run the container by choosing the [docker run](https://github.com/antlafarge/jdownloader#docker-run) or [docker compose](https://github.com/antlafarge/jdownloader#docker-compose) method and customize the parameters by using your [myJDownloader](https://my.jdownloader.org) credentials.
    - You can check the container logs : `docker logs --follow --tail 100 jdownloader` (`CTRL + C` to quit)
- Wait some minutes for JDownloader to update and be available in your [myJDownloader web interface](https://my.jdownloader.org).

## Update JDownloader

JDownloader will update itself automatically when it is idle (every 12 hours), so you have nothing to do.  
To disable the automatic upates, go to your JD instance on [my.jdownloader.org](https://my.jdownloader.org), and go to `Settings` / `Event Scripter` and switch from `Enabled` to `Disabled`.

## Update the image

The dockerhub image is rebuilt monthly to get last OS and packages security updates.
- [Docker compose](https://github.com/antlafarge/jdownloader#docker-compose) method :
    - Update the image : `docker compose pull jdownloader`
    - Recreate the container : `docker compose up -d --force-recreate jdownloader`
    - Remove the old images : `docker image prune -f`
- [Docker run](https://github.com/antlafarge/jdownloader#docker-run) method :
    - Update the image : `docker pull antlafarge/jdownloader:latest`
    - Remove the current container : `docker rm -f jdownloader`
    - Start the container : `docker run ...`
    - Remove the old images : `docker image prune -f`

## Special characters in password

- If you used the docker secrets, put the raw password in the secret file without escaping any character.
- If you want to use environment variables.
    - [Docker-compose.yml](https://github.com/antlafarge/jdownloader#docker-compose) file :
        - Escape double quotes (`"`) with backslashes (`\`)
            - ``JD_PASSWORD="My\"Great`Password"``
    - [Docker run](https://github.com/antlafarge/jdownloader#docker-run) command :
        - If you have exclamation marks (`!`) in your password and you use a **bash** shell, this special character corresponds to commands history substitution. You might need to disable it :
            - Type the command `set +H` in your bash shell.
        - Escape double quotes (`"`) or backticks (`` ` ``) with backslashes (`\`)
            - ``JD_PASSWORD="My\"Great\`Password"``
- If you want to put your password manually in the settings file :
    - Modify your [docker-compose.yml](https://github.com/antlafarge/jdownloader#docker-compose) file or [docker run](https://github.com/antlafarge/jdownloader#docker-run) command parameters :
        - Set an empty `<JD_PASSWORD>` *(for disabling password replacement on container start)* :
            - `JD_PASSWORD=""`
        - Set a `<CONFIG-PATH>` volume to have an access to the JDownloader settings files.
    - Start the container.
    - Go to your config directory and open the settings file named `org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json`.
    - Search for the password field and place your password in the empty double quotes. `"password":"MyGreatPassword",`
        - Escape double quotes (`"`) with backslashes (`\`).
            - ``"password":"My\"Great`Password",``
    - Save the file and restart the container. `docker restart jdownloader`

# Troubleshooting

## Files permissions issue

Check the user you use to run the container (with `user` parameter) can read and write the directories you created and you mounted as [volumes](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems).  
Read carefully the [Setup guide](https://github.com/antlafarge/jdownloader#setup) and follow the steps.  
Or run the container as root (remove `user` parameter).

## Armhf libseccomp2 issue

If you run the image on an armhf host (`arm/v7`), you may encounter many command errors (`wait`, `sleep`, `curl`, `date`)  
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

If many internal commands fail, your container may lack some privileges and you can try the [--privileged](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) flag.

## Nothing worked / another issue

You can report issues in the [github issues](https://github.com/antlafarge/jdownloader/issues).  
You can send feedback and discuss the project in the [github discussions](https://github.com/antlafarge/jdownloader/discussions).
