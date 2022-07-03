FROM lj020326/ubuntu2004-systemd:latest
#FROM media.johnson.int/systemd-ubuntu2004:latest
LABEL maintainer="Lee Johnson <ljohnson@dettonville.org>"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://github.com/bdellegrazie/docker-ubuntu-systemd/blob/master/Dockerfile
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    dbus systemd systemd-cron rsyslog iproute2 python python-apt sudo bash ca-certificates && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/^\(module(load="imklog")\)/#\1/' /etc/rsyslog.conf

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init", "--log-target=journal"]
#CMD ["/lib/systemd/systemd"]
