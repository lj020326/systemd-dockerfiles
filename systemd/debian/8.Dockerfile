## ref: https://stackoverflow.com/questions/74531081/debian-8-jessie-archive-debian-org-gpg-error-keyexpired-since-2022-11-19-what-n
#FROM debian:jessie
FROM debian/eol:jessie
LABEL maintainer="Lee Johnson <lee.james.johnson@gmail.com>"
LABEL build="2023010401"

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## ref: https://stackoverflow.com/questions/52939411/build-error-failed-to-fetch-http-deb-debian-org-debian-dists-jessie-updates-m
#RUN echo "deb http://deb.debian.org/debian jessie main" > /etc/apt/sources.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y systemd systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## using approach used here:
## https://github.com/WyseNynja/dockerfile-debian/blob/jessie/Dockerfile
COPY ./docker-apt-install.sh /usr/local/sbin/docker-install

## ref: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
## deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main
RUN set -eux; \
    docker-install systemd systemd-sysv

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && rm $(ls | grep -v systemd-tmpfiles-setup)

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/sbin/init"]
#CMD ["/lib/systemd/systemd"]
