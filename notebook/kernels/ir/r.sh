#!/usr/bin/env bash

# setup environment variable, etc.
if [ "$INGEN_STAMMER_TAKK" == "" ]; then
        source /etc/profile.d/stamme_variabel
fi

export FELLES="/ssb/bruker/felles"
export R_PROFILE_USER="/opt/conda/share/jupyter/kernels/ir/Rstartup"
export R_LIBS_USER="/usr/lib/R/library"

# Run IRkernel
exec /usr/bin/R --slave -e "IRkernel::main()" $@
