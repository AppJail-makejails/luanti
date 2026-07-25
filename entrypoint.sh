#!/bin/sh

. /lib.subr

set -e

if [ "${1#-}" != "$1" ]; then
    set -- luantiserver "$@"
fi

if [ "$1" = "luantiserver" ] || [ "$1" = "luanti" ]; then
    set_homedir /var/db/minetest

    create_user

    set -- su-exec noroot "$@"
fi

exec "$@"
