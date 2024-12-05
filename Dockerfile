# docker build -t zelbanna/dhcpd:latest -t zelbanna/dhcpd:1.0 .
# docker push -a zelbanna/dhcpd
FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Zacharias El Banna  <zacharias@elbanna.se>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -q -y update \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     apt-utils dumb-init isc-dhcp-server man \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*

ENV DHCPD_PROTOCOL=4

COPY util/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
