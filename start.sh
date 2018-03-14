#!/bin/sh
/etc/init.d/dbus start
/etc/init.d/avahi-daemon start
sleep 8

jackd -R -d net &
/mumble/release/mumble "$@" &
wait