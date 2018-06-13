FROM devopsinitiative/webmethods-microservicesruntime:latest

USER root

RUN  yum -y update && \
     yum install -y yum-utils \
	    device-mapper-persistent-data \
	      lvm2 && \
     yum-config-manager \
	      --add-repo \
	          https://download.docker.com/linux/centos/docker-ce.repo && \
     yum install -y docker-ce

# Install a basic SSH server
RUN yum install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Install JDK 8 (latest edition)
RUN yum install -y java-1.8.0-openjdk

#Enable Root Login
RUN echo 'root:jenkins' | chpasswd

RUN yum -y install openssh-server epel-release && \
    yum -y install pwgen && \
    rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -A && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \ 
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Standard SSH port
EXPOSE 22
ADD start-jenkins-slave.sh /usr/bin/start-jenkins-slave.sh
CMD ["start-jenkins-slave.sh"]

USER jenkins
