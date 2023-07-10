ARG IMAGE_REGISTRY=lj020326
FROM $IMAGE_REGISTRY/centos9-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023071001"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# ref: https://namespaceit.com/blog/failed-to-download-metadata-for-repo-appstream-cannot-prepare-internal-mirrorlist-no-urls-in-mirrorlist
#RUN sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* &&\
#    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
#RUN sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* &&\
#    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://mirror.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

COPY ./repos/centos8-linux-baseOS.repo.ini /etc/yum.repos.d/CentOS-Linux-BaseOS.repo
COPY ./repos/centos8-linux-extras.repo.ini /etc/yum.repos.d/CentOS-Linux-Extras.repo
COPY ./repos/centos8-linux-appstream.repo.ini /etc/yum.repos.d/CentOS-Linux-AppStream.repo

RUN dnf upgrade -y

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-8
RUN dnf makecache && \
    dnf install --nodocs -y \
        sudo \
        bash \
        python3 && \
    dnf clean all

RUN systemctl set-default multi-user.target

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

# The host's cgroup filesystem need's to be mounted (read-only) in the
# container. '/run', '/run/lock' and '/tmp' need to be tmpfs filesystems when
# running the container without 'CAP_SYS_ADMIN'.
#
# NOTE: For running Debian stretch, 'CAP_SYS_ADMIN' still needs to be added, as
#       stretch's version of systemd is not recent enough. Buster will run just
#       fine without 'CAP_SYS_ADMIN'.
#VOLUME [ "/sys/fs/cgroup" ]
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

# A different stop signal is required, so systemd will initiate a shutdown when
# running 'docker stop <container>'.
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
#CMD ["/usr/sbin/init"]
#CMD ["/usr/lib/systemd/systemd"]