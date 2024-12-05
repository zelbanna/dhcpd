Docker image for ISC DHCP server
================================

This Docker image is suitable for running a DHCP server for your docker host
network. It is based on ISC DHCP server which is bundled with the latest Debian
distribution.

How to build
============

 1. Install Docker with the instructions on <https://www.docker.com>.
 2. Check head of Dockerfile :-)

How to use
==========

Provide DHCP service to the host network of the machine running Docker. For that you need
to create a configuration for the DHCP server, start the container with the 
`--net host` docker run option (or using compose) and specify the network interfaces you 
want to provide DHCP service on, as commands in the case of compose.

 1. Create `data` folder for config and leases.
 2. Create `data/dhcpd.conf` with subnet clauses for the specified
    network interfaces. 
 3. Run `docker run -it --rm --init --net host -v "$(pwd)/data":/data networkboot/dhcpd [<interfaces>]`.
    `dhcpd` will automatically start and display its logs on the console.
 4. Create a docker compose or copy content and modify for customized running DHCP server

DHCPv6
------

To use a DHCPv6-Server you have to pass `DHCPD_PROTOCOL=6` as enviroment variable

Notes
=====

The entrypoint script in the docker image takes care of running the DHCP
server as the same user that owns the `data` folder.  This ensures that the
permissions on the files inside the `data` folder is kept consistent.

If a `/data` volume is not provided with a `dhcpd.conf` inside it, the
container will exit early with an error message.

Copyright & License
===================

It is licensed under the Apache 2.0 license.

See the file LICENSE for full legal details.
