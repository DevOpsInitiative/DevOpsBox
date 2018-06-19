#!/bin/bash

export JAVA_HOME=/opt/softwareag/jvm/jvm/
export PATH=$JAVA_HOME/bin:$PATH

touch /opt/softwareag/IntegrationServer/Instances/default/logs/server.log
/opt/softwareag/profiles/IS_default/bin/startup.sh

tail -f /opt/softwareag/IntegrationServer/Instances/default/logs/server.log