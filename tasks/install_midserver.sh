#!/bin/bash

useradd $PT_non_root_midserver_user

host=https://install.service-now.com
ca_cert_path=$(puppet config print cacert)

if [ $PT_sn_instance_version == "Paris" ]; then
  path=glide/distribution/builds/package/app-signed/mid/2020/10/20
  file=mid.paris-06-24-2020__patch2-10-01-2020_10-20-2020_1602.linux.x86-64.zip
  curl "$host/$path/$file" -O
  mkdir -p /opt/servicenow/mid
  apt install unzip
  unzip $file -d /opt/servicenow/mid/
elif [ $PT_sn_instance_version == "Quebec" ]; then
  path=glide/distribution/builds/package/app-signed/mid-linux-installer/2021/01/15
  file=mid-linux-installer.quebec-12-09-2020__patch0-hotfix2-01-08-2021_01-15-2021_1853.linux.x86-64.deb
  curl "$host/$path/$file" -O
  dpkg -i $file
else
  echo "Only Paris or Quebec ServiceNow versions are supported."
  exit 1
fi

/opt/servicenow/mid/agent/installer.sh \
      -silent \
      -INSTANCE_URL $PT_sn_instance \
      -USE_PROXY N \
      -MID_USERNAME $PT_mid_username \
      -MID_PASSWORD $PT_mid_password \
      -MID_NAME $PT_midserver_name \
      -APP_NAME $PT_app_name \
      -APP_LONG_NAME $PT_app_long_name \
      -NON_ROOT_USER $PT_non_root_midserver_user

/opt/servicenow/mid/agent/jre/bin/keytool \
        -import \
        -alias puppet \
        -file $ca_cert_path \
        -keystore /opt/servicenow/mid/agent/jre/lib/security/cacerts \
        -storepass $PT_java_keystore_password \
        -noprompt 