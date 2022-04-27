#!/bin/bash
set -e

ln -s /opt/jwsacruncher-2.2.4/bin/jwsacruncher /usr/bin/jwsacruncher

exec "$@"
