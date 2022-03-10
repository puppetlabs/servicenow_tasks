#!/bin/bash

if [ $(id -u) != "0" ]
    then
        sudo su
fi

useradd $PT_run_as_user
cert_path=$(puppet config print cacert)

host="https://install.service-now.com"

if [ $PT_sn_instance_version == "Quebec" ]; then
    path=/glide/distribution/builds/package/app-signed/mid-linux-installer/2021/03/25/
    file=mid-linux-installer.quebec-12-09-2020__patch2-03-17-2021_03-25-2021_1921.linux.x86-64.deb
elif [ $PT_sn_instance_version == "Rome" ]; then
    path=/glide/distribution/builds/package/app-signed/mid-linux-installer/2022/01/18/
    file=mid-linux-installer.rome-06-23-2021__patch6-01-13-2022_01-18-2022_0138.linux.x86-64.deb
elif [$PT_sn_instance_version == "San Diego"]; then
    path=/glide/distribution/builds/package/app-signed/mid-linux-installer/2022/02/01/
    file=mid-linux-installer.sandiego-12-22-2021__patch0-hotfix1-02-01-2022_02-01-2022_2323.linux.x86-64.deb
else
    echo "Only Quebec, Rome and San Diego ServiceNow versions are supported."
    exit 1
fi

if which curl >/dev/null ; then
    echo "Downloading via curl."
    curl "$host/$path/$file" -O
else
    echo "Please install curl to use this task."
    exit 1
fi

apt install dpkg
dpkg -i $file

/opt/servicenow/mid/agent/installer.sh \
      -silent \
      -INSTANCE_URL $PT_servicenow_instance_url \
      -USE_PROXY N \
      -MID_USERNAME $PT_midserver_username \
      -MID_PASSWORD $PT_midserver_password \
      -MID_NAME $PT_midserver_name \
      -APP_NAME $PT_app_name \
      -APP_LONG_NAME $PT_app_long_name \
      -NON_ROOT_USER $PT_app_run_as_user

/opt/servicenow/mid/agent/jre/bin/keytool \
    -import \
	-alias puppet \
	-file $cert_path \
	-keystore /opt/servicenow/mid/agent/jre/lib/security/cacerts \
	-noprompt
