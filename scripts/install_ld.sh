#!/bin/bash
set -x

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

TERRAFORM_VERSION="0.11.7"
PACKER_VERSION="0.10.2"
# create new ssh key
if [ ${REDHAT_BASED} ] ; then
  [[ ! -f /home/vagrant/.ssh/mykey ]] \
  && mkdir -p /home/vagrant/.ssh \
  && ssh-keygen -f /home/vagrant/.ssh/mykey -N '' \
  && chown -R vagrant:vagrant /home/vagrant/.ssh
else
  [[ ! -f /home/ubuntu/.ssh/mykey ]] \
  && mkdir -p /home/ubuntu/.ssh \
  && ssh-keygen -f /home/ubuntu/.ssh/mykey -N '' \
  && chown -R ubuntu:ubuntu /home/ubuntu/.ssh
fi
# install packages
if [ ${REDHAT_BASED} ] ; then
  yum -y update
  yum install -y yum-utils \
	    device-mapper-persistent-data \
	      lvm2
  yum-config-manager \
	      --add-repo \
	          https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce ansible unzip wget
else 
  apt-get update
  apt-get -y install docker.io ansible unzip
fi
# add docker privileges
if [ ${REDHAT_BASED} ] ; then
  usermod -G docker vagrant
else
  usermod -G docker ubuntu
fi
# install pip
pip install -U pip && pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi
# install awscli and ebcli
pip install -U awscli
pip install -U awsebcli

#kubectl
if [ ${REDHAT_BASED} ] ; then
  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
  yum install -y kubectl
else 
  apt-get update && apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
  apt-get update
  apt-get install -y kubectl
fi
#terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(/usr/local/bin/packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

#Google Chrome
if [ ${REDHAT_BASED} ] ; then
  cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
  yum install -y google-chrome-stable xorg-x11-xauth gtk2.x86_64
else 
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"  > /etc/apt/sources.list.d/google-chrome.list
  apt-get install -y google-chrome-stable xorg-x11-xauth gtk2.x86_64
fi

#git
if [ ${REDHAT_BASED} ] ; then
  yum install -y git
else 
  apt-get install -y git/opt/softwareag
fi

#java
if [ ${REDHAT_BASED} ] ; then
  yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/c/cabextract-1.5-1.el7.x86_64.rpm https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
else
  apt-get install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/c/cabextract-1.5-1.el7.x86_64.rpm https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
fi
  
#Integration Server
mkdir /opt/softwareag
chown vagrant:vagrant /opt/softwareag
chmod 777 /opt/softwareag

su - vagrant -c "java -jar /vagrant/scripts/SoftwareAGInstaller.jar -readImage /vagrant/scripts/is_designer_rhel_x86-64.zip  -readScript /vagrant/scripts/is_designer_install.script"
/opt/softwareag/bin/afterInstallAsRoot.sh
su - vagrant -c "/opt/softwareag/profiles/IS_default/bin/startup.sh"

echo "****** SAG_HOME:                  /opt/softwareag                  ******"

# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi
