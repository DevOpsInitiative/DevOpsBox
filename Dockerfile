FROM centos:7

USER root

RUN useradd -U vagrant && echo "vagrant:pswerd123" | chpasswd
RUN mkdir -p /vagrant/scripts

COPY scripts/* /vagrant/scripts/

RUN cd /vagrant/scripts; ./install_ld.sh

USER vagrant

CMD /vagrant/scripts/start_ld.sh
