ARG IMAGE_REGISTRY=media.johnson.int:5000
FROM $IMAGE_REGISTRY/centos7-systemd:latest
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2022121501"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

#COPY ./centos-os.repo.ini /etc/yum.repos.d/centos-os.repo
#COPY ./centos-extras.repo.ini /etc/yum.repos.d/centos-extras.repo

# Dependencies for Ansible
## MUST install devel libs for python-ldap to work
## ref: https://github.com/bdellegrazie/docker-centos-systemd/blob/master/Dockerfile-7
## MUST install devel libs for python-ldap to work
#RUN yum makecache fast && yum install -y python sudo yum-plugin-ovl bash && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all
RUN yum install -y \
    sudo \
    bash \
    python

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
VOLUME [ "/sys/fs/cgroup" ]

# A different stop signal is required, so systemd will initiate a shutdown when
# running 'docker stop <container>'.
STOPSIGNAL SIGRTMIN+3

CMD ["/usr/sbin/init"]
