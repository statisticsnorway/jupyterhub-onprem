import os

# Configuration file for JupyterHub
c = get_config()

# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.

# Spawn single-user servers as Docker containers
c.JupyterHub.spawner_class = "dockerspawner.SystemUserSpawner"

# Normalize username, so if user logs in with domain, username@ssb.no
# then the domain will be cut out once the users notebook server is spawned
c.PAMAuthenticator.pam_normalize_username = True


# Remove users that are no longer able to authenticate
c.Authenticator.delete_invalid_users = True

# Spawn containers from this image
c.DockerSpawner.container_image = os.environ["DOCKER_NOTEBOOK_IMAGE"]

# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
spawn_cmd = os.environ.get("DOCKER_SPAWN_CMD", "start-singleuser.sh")

# 'user: root' must be set so the user container is spawned as root,
# this allows changes to NB_USER, NB_UID and NB_GID
c.DockerSpawner.extra_create_kwargs.update({ "command": spawn_cmd, "user": "root"})

# Connect containers to this Docker network
network_name = os.environ["DOCKER_NETWORK_NAME"]

c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name

# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { "network_mode": network_name}

# Memory limits
# Documentation https://jupyterhub-dockerspawner.readthedocs.io/en/latest/api/index.html
c.DockerSpawner.mem_guarantee = "1G"
c.DockerSpawner.mem_limit = "2G"

# Mounting /ssb/bruker from the jupyterhub container to the user container
c.DockerSpawner.volumes = { 
        "/ssb/bruker": "/ssb/bruker",
        "/ssb/share": "/ssb/share",
        "/ssb/stamme01": "/ssb/stamme01",
        "/ssb/stamme02": "/ssb/stamme02",
        "/ssb/stame03": "/ssb/stamme03",
        "/ssb/stamme04": "/ssb/stamme04",
        "/ssb/x_disk": "/ssb/x_disk"
}

# host_homedir_format_string must be set to map /ssb/bruker/{username} to /home/{username}
c.SystemUserSpawner.host_homedir_format_string = "/ssb/bruker/{username}"

# Remove containers once they are stopped
c.DockerSpawner.remove_containers = True

# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = "jupyterhub"
c.JupyterHub.hub_port = 8080

# TLS config
c.JupyterHub.port = 443
c.JupyterHub.ssl_key = os.environ["SSL_KEY"]
c.JupyterHub.ssl_cert = os.environ["SSL_CERT"]

# Persist hub data on volume mounted inside container
data_dir = os.environ.get("DATA_VOLUME_CONTAINER", "/data")

c.JupyterHub.cookie_secret_file = os.path.join(data_dir,
    "jupyterhub_cookie_secret")

c.JupyterHub.db_url = "postgresql://postgres:{password}@{host}/{db}".format(
    host=os.environ["POSTGRES_HOST"],
    password=os.environ["POSTGRES_PASSWORD"],
    db=os.environ["POSTGRES_DB"],
)
