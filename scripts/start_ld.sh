#!/bin/bash

export JAVA_HOME=/opt/softwareag/jvm/jvm/
export PATH=$JAVA_HOME/bin:$PATH

mkdir /opt/softwareag/IntegrationServer/instances/default/logs
touch /opt/softwareag/IntegrationServer/instances/default/logs/server.log
/opt/softwareag/profiles/IS_default/bin/startup.sh

tail -f /opt/softwareag/IntegrationServer/instances/default/logs/server.log