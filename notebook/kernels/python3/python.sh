#!/usr/bin/env bash

# setup environment variable, etc.
if [ "$INGEN_STAMMER_TAKK" == "" ]; then
        source /etc/profile.d/stamme_variabel
fi

export FELLES="/ssb/bruker/felles"

# run the ipykernel
exec /opt/conda/bin/python -m ipykernel $@
