FROM docker.io/archlinux:latest
RUN pacman --sync --refresh --noconfirm reflector
RUN reflector --save /etc/pacman.d/mirrorlist \
              --protocol https \
              --latest 5 \
              --sort rate
RUN pacman --sync --noconfirm mkinitcpio
RUN sed -i 's/autodetect //' /etc/mkinitcpio.conf
RUN pacman --sync --noconfirm base linux linux-firmware
RUN yes | pacman --sync iptables-nft
RUN pacman --sync --noconfirm lxd

RUN echo "lxc.idmap = u 0 100000 65536" >> /etc/lxc/default.conf
RUN echo "lxc.idmap = g 0 100000 65536" >> /etc/lxc/default.conf
RUN echo "root:100000:65536" > /etc/subuid
RUN echo "root:100000:65536" > /etc/subgid

COPY config/lxd/preseed.yml /config/lxd/preseed.yml

#COPY config/lxd/lxd.conf /usr/lib/systemd/system/lxd.service.d/lxd.conf

COPY config/lxd/lxd-init.service /etc/systemd/system/lxd-init.service
COPY config/lxd/container@.service /etc/systemd/system/container@.service
RUN systemctl enable lxd.service
RUN systemctl enable lxd-init.service

RUN echo "root:root" | chpasswd

COPY config/install.conf /etc/systemd/system/systemd-firstboot.service.d/install.conf
COPY config/10-login.conf /etc/systemd/logind.conf.d/10-login.conf
COPY config/20-wired.network /etc/systemd/network/20-wired.network