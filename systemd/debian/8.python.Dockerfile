FROM lj020326/debian8-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-debian-systemd/blob/master/Dockerfile
#RUN apt-get update && \
#    apt-get install --no-install-recommends -y \
#        dbus systemd systemd-cron rsyslog iproute2 \
#        sudo bash ca-certificates \
#        python python-apt bash \
#        libldap2-dev libsasl2-dev slapd ldap-utils \
#        build-essential python-dev \
#        python-pip \
#        && \
#    apt-get clean && \
#    rm -rf /usr/share/doc /usr/share/man /var/lib/apt/lists/* /tmp/* /var/tmp/*


## using approach used here:
## https://github.com/WyseNynja/dockerfile-debian/blob/jessie/Dockerfile
COPY ./docker-apt-install.sh /usr/local/sbin/docker-install

## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main
#RUN set -eux; \
#    echo "deb http://ftp.debian.org/debian jessie-backports main" >/etc/apt/sources.list.d/backports.list; \
#    docker-install bash sudo rsyslog ca-certificates python python-apt

## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main
RUN set -eux; \
    docker-install \
        dbus systemd systemd-cron rsyslog iproute2 \
        sudo bash ca-certificates \
        python python-apt python-pip \
        libldap2-dev libsasl2-dev slapd ldap-utils \
        build-essential python-dev

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init", "--log-target=journal"]
#CMD ["/lib/systemd/systemd"]
