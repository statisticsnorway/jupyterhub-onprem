
#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

# The Jupyter command to launch
# JupyterLab by default
DOCKER_STACKS_JUPYTER_CMD="${DOCKER_STACKS_JUPYTER_CMD:=lab}"

if [[ -n "${JUPYTERHUB_API_TOKEN}" ]]; then
    echo "WARNING: using start-singleuser.sh instead of start-notebook.sh to start a server associated with JupyterHub."
    exec /usr/local/bin/start-singleuser.sh "$@"
fi

wrapper=""
if [[ "${RESTARTABLE}" == "yes" ]]; then
    wrapper="run-one-constantly"
fi

# if container is started as root we pull and install firewall certificate for github
if [ "$(id -u)" == 0 ] ; then
    wget https://nexus.ssb.no/repository/certificate_repo/ssb/cert_Decrypt-CA.crt -P /tmp/
    cp /tmp/cert_Decrypt-CA.crt /usr/local/share/ca-certificates
    update-ca-certificates
fi

# shellcheck disable=SC1091,SC2086
exec /usr/local/bin/start.sh ${wrapper} jupyter ${DOCKER_STACKS_JUPYTER_CMD} ${NOTEBOOK_ARGS} "$@"