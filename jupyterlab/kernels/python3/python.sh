#!/usr/bin/env bash

source /etc/profile.d/stamme_variabel

export FELLES=/ssb/bruker/felles

exec /opt/conda/bin/python -m ipykernel $@