#!/usr/bin/env bash

source /etc/profile.d/stamme_variabel

export FELLES=/ssb/bruker/felles
export PYTHONPATH=$PYTHONPATH:/ssb/bruker/felles/pythonForSsb

exec /opt/conda/bin/python -m ipykernel $@