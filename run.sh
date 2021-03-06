#!/bin/bash

# Check env vars
if [ -z "${JD_EMAIL}" ] || [ -z "${JD_PASSWORD}" ]; then
    echo "Environment variable JD_EMAIL or JD_PASSWORD has not been set"
    exit 1
fi

# Get current GID
currentGID=$(cut -d: -f3 < <(getent group jdgroup))

# If current GID does not match
if [ "$currentGID" != "${GID}" ]; then

    echo "GID does not match (currentGID='$currentGID', GID='${GID}')"

    # If current GID is set (not null or not empty)
    if [ ! -z "$currentGID" ]; then

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
currentUID=$(id -u jduser)

# If current UID does not match
if [ "$currentUID" != "${UID}" ]; then

    echo "UID does not match (currentUID='$currentUID', UID='${UID}')"

    # If current UID is set (not null or not empty)
    if [ ! -z "$currentUID" ]; then

        echo "Delete user"

        # delete user
        deluser jduser

        # delete home directory
        rm -R /home/jduser

    fi

    echo "Create user with UID '${UID}'"

    # Create user and add to group
    useradd -ms /bin/bash -d /home/jduser -u ${UID} -G jdgroup jduser

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
echo "{ \"autoconnectenabledv2\" : true, \"email\": \"${JD_EMAIL}\", \"password\": \"${JD_PASSWORD}\", \"devicename\": \"${JD_NAME}\" }" > ./cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json

# JDownloader.jar can be invalid or corrupted after an update, so we delete it and download the last jar file at startup

# If file JDownloader.jar exists
if [ -f "./JDownloader.jar" ]; then

    echo "Deleting JDownloader.jar"

    # Delete JDownloader.jar
    rm JDownloader.jar

    echo "JDownloader.jar deleted"

fi

echo "Downloading JDownloader.jar"

# Download jdownloader
wget http://installer.jdownloader.org/JDownloader.jar

echo "JDownloader.jar downloaded"

echo "Setup access rights to current directory"

# Set access rigths
chown -R jduser:jdgroup .
chmod -R 777 .

echo "Starting JDownloader.jar"

# Start jdownloader
su jduser -c "java -Djava.awt.headless=true -jar JDownloader.jar"
