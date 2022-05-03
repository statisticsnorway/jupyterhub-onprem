#!/bin/sh

export FROM_ENVSH=true

# Tried adding all of the lines below in Dockerfile but failed.
# For some reason stamme_variabel could not be read
# and oracle didn't "find" the oracle variabels.
# I checked and the environment variables did exist.
# Because this file runs every time a user starts a server
# we ensure the user gets the environment variables needed.

# Get all variables from stamme_variabel
source /etc/profile.d/stamme_variabel

export FELLES="/ssb/bruker/felles"

# Setting up environment variables for pip and pipenv
# Pip config so users install from Nexus.
export PIP_INDEX=http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/pypi
export PIP_INDEX_URL=http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/simple
export PIPENV_PYPI_MIRROR=$PIP_INDEX_URL
export PIP_TRUSTED_HOST=pl-nexuspro-p.ssb.no
export PIP_REQUIRE_VIRTUALENV=true

# Setting up environment variables for oracle
export OCI_INC=/usr/include/oracle/21/client64
export ORACLE_HOME=/usr/lib/oracle/21/client64
export TNS_ADMIN=/usr/lib/oracle/21/client64/lib/network
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/21/client64/lib
