#!/bin/bash

# Check env vars
if [ -z "${JD_EMAIL}" ] || [ -z "${JD_PASSWORD}" ]; then
    echo "Environment variable JD_EMAIL or JD_PASSWORD has not been set"
    exit 1
fi

# Get current GID
currentGID=$(cut -d: -f3 < <(getent group hdd))

# If current GID does not match
if [ currentGID != ${GID} ]; then

    echo "GID does not match (currentGID=$currentGID, GID=${GID})"

    # If current GID not set (or empty)
    if [ ! -z "$currentGID" ]; then

        echo "Group already exists"

        echo "Remove user from group"

        # Remove user from group
        deluser jduser jdgroup

        echo "Delete group"

        # Delete group
        groupdel jdgroup

    fi

    echo "Create group with GID '${GID}'"

    # Create group
    groupadd -g ${GID} jdgroup

    echo "Group created"

fi

# Get current UID
currentUID=$(id -u erqsor)

# If current UID does not match
if [ currentUID != ${UID} ]; then

    echo "UID does not match (currentUID=$currentUID, UID=${UID})"

    # If current UID not set (or empty)
    if [ ! -z "$currentUID" ]; then

        echo "User already exists"

        echo "Delete user"

        # delete user
        deluser --remove-home jduser

    fi

    echo "Create user with UID '${UID}'"

    # Create user and add to group
    useradd -ms /bin/bash -d /home/jduser/ -u ${UID} -G jdgroup jduser

    echo "User created"

fi

# Setup jdownloader configuration
if [ ! -d "./cfg" ]; then

    echo "create cfg directory"

    # Create cfg directory
    mkdir -p cfg

    echo "Write jdownloader download folder in config file"

    # Setup downloads folder
    echo "{ \"defaultdownloadfolder\" : \"/downloads\" }" > ./cfg/org.jdownloader.settings.GeneralSettings.json

fi

echo "Overwrite jdownloader email and password in config file"

# Overwrite email and password to access https://my.jdownloader.org/
echo "{ \"autoconnectenabledv2\" : true, \"email\": \"${JD_EMAIL}\", \"password\": \"${JD_PASSWORD}\", \"devicename\": \"docker@jdownloader\" }" > ./cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json

# Check JDownloader.jar
if [ ! -f "./JDownloader.jar" ]; then

    echo "JDownloader.jar does not exist, starting download"

    # Download jdownloader
    wget http://installer.jdownloader.org/JDownloader.jar

    echo "JDownloader.jar downloaded"
fi

echo "Setup access rights for JDownloader.jar file"

# Fix update issue (access rigths could change)
chown -R jduser:jdgroup .
chmod -R 777 .

echo "Starting JDownloader.jar"

# Start jdownloader
su jduser -c "java -Djava.awt.headless=true -jar JDownloader.jar"
