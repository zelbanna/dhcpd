#!/bin/bash

set -e

# Support docker run --init parameter which obsoletes the use of dumb-init,
# but support dumb-init for those that still use it without --init
if [ $$ -eq 1 ]; then
    run="exec /usr/bin/dumb-init --"
else
    run="exec"
fi

IFACES=""
for VAR in "$@"; do
    # skip wait-for-interface behavior if found in path
    if ! which "$VAR" >/dev/null; then
        # loop until interface is found, or we give up
        NEXT_WAIT_TIME=1
        until [ -e "/sys/class/net/$VAR" ] || [ $NEXT_WAIT_TIME -eq 4 ]; do
            sleep $(( NEXT_WAIT_TIME++ ))
            echo "Waiting for interface '$VAR' to become available... ${NEXT_WAIT_TIME}"
        done
        if [ -e "/sys/class/net/$VAR" ]; then
            IFACES="$VAR $IFACES"
        fi
    fi
done

# Run dhcpd for specified interface or all interfaces

data_dir="/data"
if [ ! -d "$data_dir" ]; then
    echo "Please ensure '$data_dir' folder is available."
    echo 'If you just want to keep your configuration in "data/", add -v "$(pwd)/data:/data" to the docker run command line.'
    exit 1
fi

dhcpd_conf="$data_dir/dhcpd.conf"
if [ ! -r "$dhcpd_conf" ]; then
    echo "Please ensure '$dhcpd_conf' exists and is readable."
    echo "Run the container with arguments 'man dhcpd.conf' if you need help with creating the configuration."
    exit 1
fi

uid=$(stat -c%u "$data_dir")
gid=$(stat -c%g "$data_dir")
uname=$(id -nu $uid)
gname=$(id -ng $gid)
echo "Running DHCPd with $uid:$gid rights"

[ -e "$data_dir/dhcpd.leases" ] || touch "$data_dir/dhcpd.leases"
chown $uid:$gid "$data_dir/dhcpd.leases"
if [ -e "$data_dir/dhcpd.leases~" ]; then
    chown $uid:$gid "$data_dir/dhcpd.leases~"
fi

$run /usr/sbin/dhcpd -$DHCPD_PROTOCOL -f -d --no-pid -cf "$data_dir/dhcpd.conf" -lf "$data_dir/dhcpd.leases" -user $uname -group $gname $IFACES
