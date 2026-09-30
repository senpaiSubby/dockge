#!/bin/sh
# SSH keys for the Update button's git pull can be mounted read-only at /root/.ssh-host.
# ssh refuses a config file owned by another user (e.g. the TrueNAS admin user),
# so copy them into /root/.ssh owned by root with strict permissions.
if [ -d /root/.ssh-host ]; then
    mkdir -p /root/.ssh
    cp -rL /root/.ssh-host/. /root/.ssh/
    chown -R root:root /root/.ssh
    chmod 700 /root/.ssh
    find /root/.ssh -type f -exec chmod 600 {} +
fi

exec "$@"
