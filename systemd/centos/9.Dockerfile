#FROM centos:9

## ref: https://www.server-world.info/en/note?os=CentOS_Stream_9&p=docker&f=1
FROM quay.io/centos/centos:stream9
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build_date="2023-07-10"

ENV container docker

## ref: https://github.com/geerlingguy/docker-centos8-ansible/blob/master/Dockerfile
RUN (cd /lib/systemd/system/sysinit.target.wants/; \
for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/*

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

#VOLUME [ "/sys/fs/cgroup" ]
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

CMD ["/sbin/init"]
#CMD ["/usr/sbin/init"]
#CMD ["/usr/lib/systemd/systemd"]
