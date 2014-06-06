#
# Ubuntu Desktop (Gnome) Dockerfile
#
# https://github.com/intlabs/dockerfile-ubuntu-application-broadway
#

# Install GNOME3 and VNC server.
# (c) Pete Birley

# Pull base image.
FROM ubuntu:13.04

# Setup enviroment variables
ENV DEBIAN_FRONTEND noninteractive

#Update the package manager and upgrade the system
RUN apt-get update && \
apt-get upgrade -y && \
apt-get update

# Upstart and DBus have issues inside docker.
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

#Install ssh server
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd 

#Create user
RUN adduser --disabled-password --gecos "" user
RUN echo 'user:acoman' |chpasswd

#you can ssh into this container ssh user@<host> -p <whatever 22 has been mapped to>

# Installing fuse filesystem is not possible in docker without elevated priviliges
# but we can fake installling it to allow packages we need to install for GNOME
RUN apt-get install libfuse2 -y && \
cd /tmp ; apt-get download fuse && \
cd /tmp ; dpkg-deb -x fuse_* . && \
cd /tmp ; dpkg-deb -e fuse_* && \
cd /tmp ; rm fuse_*.deb && \
cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst && \
cd /tmp ; dpkg-deb -b . /fuse.deb && \
cd /tmp ; dpkg -i /fuse.deb

# Update the package lists for good measure
RUN apt-get update

# Install Xorg
RUN apt-get install -y xorg

# Install VNC server
RUN apt-get install -y tightvncserver
# Set up VNC
RUN apt-get install -y expect
RUN mkdir -p /root/.vnc
ADD xstartup /root/.vnc/xstartup
RUN chmod 755 /root/.vnc/xstartup
ADD start-vnc-expect-script.sh /usr/local/etc/start-vnc-expect-script.sh
RUN chmod +x /usr/local/etc/start-vnc-expect-script.sh
ADD vnc.conf /etc/vnc.conf

#Install noVNC
RUN apt-get install -y git python-numpy net-tools
RUN cd / && git clone git://github.com/kanaka/noVNC && cp noVNC/vnc_auto.html noVNC/index.html


# Install the application to serve
RUN apt-get install -y gedit

#Bring In startup script
ADD startup.sh /etc/startup.sh
RUN chmod +x /etc/startup.sh

# default command
CMD bash -C '/etc/startup.sh';'bash'


# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Expose ports.
EXPOSE 22
# Expose ports.
EXPOSE 8080
# Expose ports.
EXPOSE 80