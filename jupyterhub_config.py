# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os

c = get_config()

# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.

# Spawn single-user servers as Docker containers
import dockerspawner
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'

from tornado import gen
from ldapauthenticator import LDAPAuthenticator
class LDAPAuthenticatorExtend(LDAPAuthenticator):
    @gen.coroutine
    def pre_spawn_start(self, user, spawner):
        self.log.debug('running preSpawn hook')
        auth_state = yield spawner.user.get_auth_state()
       
        if not auth_state:
            return

        self.log.debug('pre_spawn_start auth_state:%s' % auth_state)
        spawner.environment["NB_UID"] = str(auth_state["uidNumber"][0])
        spawner.environment["NB_GID"] = str(auth_state["gidNumber"][0])
        spawner.environment["NB_USER"] = str(auth_state["sAMAccountName"][0])

# LDAP Authentication
#c.JupyterHub.authenticator_class = 'ldapauthenticator.LDAPAuthenticator'
c.JupyterHub.authenticator_class = LDAPAuthenticatorExtend

c.LDAPAuthenticator.server_address = 'ldap.ssb.no'
c.LDAPAuthenticator.lookup_dn = True
c.LDAPAuthenticator.lookup_dn_search_filter = '({login_attr}={login})'
c.LDAPAuthenticator.lookup_dn_search_user = 'jupyterhub_ldap_search'
c.LDAPAuthenticator.lookup_dn_search_password = 'zQ9LaFLBqYYssKAC'
c.LDAPAuthenticator.user_search_base = 'OU=Brukere,OU=SSB,DC=ssb,DC=no'
c.LDAPAuthenticator.user_attribute = 'sAMAccountName'
c.LDAPAuthenticator.lookup_dn_user_dn_attribute = 'cn'
c.LDAPAuthenticator.escape_userdn = False
c.LDAPAuthenticator.use_ssl = True
# LDAPAuthenticator.enable_auth_state must be enabled to get attributes for LDAP set in auth_state_attributes.
# In addition JUPYTERHUB_CRYPT_KEY must be set in .env to a random string
c.LDAPAuthenticator.enable_auth_state = True
c.LDAPAuthenticator.auth_state_attributes = ['uidNumber', 'gidNumber', 'sAMAccountName']
c.LDAPAuthenticator.bind_dn_template = [
    "CN={username},OU=Brukere,OU=SSB,DC=ssb,DC=no"
]

# Spawn containers from this image
c.DockerSpawner.container_image = os.environ['DOCKER_NOTEBOOK_IMAGE']
# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
spawn_cmd = os.environ.get('DOCKER_SPAWN_CMD', "start-singleuser.sh")
c.DockerSpawner.extra_create_kwargs.update({ 'command': spawn_cmd, 'user': 'root'})


#test
#c.DockerSpawner.cmd = ['jupyterhub-singleuser']

# Connect containers to this Docker network
network_name = os.environ['DOCKER_NETWORK_NAME']
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { 'network_mode': network_name}

# Memory limits
# Documentation https://jupyterhub-dockerspawner.readthedocs.io/en/latest/api/index.html
c.DockerSpawner.mem_guarantee = "1G"
c.DockerSpawner.mem_limit = "2G"

# Explicitly set notebook directory because we'll be mounting a host volume to
# it.  Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir = os.environ.get('DOCKER_NOTEBOOK_DIR') or '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir
# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': notebook_dir, '/ssb/bruker': '/ssb/bruker'}
# volume_driver is no longer a keyword argument to create_container()
# c.DockerSpawner.extra_create_kwargs.update({ 'volume_driver': 'local' })
# Remove containers once they are stopped
c.DockerSpawner.remove_containers = True
# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = 'jupyterhub'
c.JupyterHub.hub_port = 8080

# TLS config
c.JupyterHub.port = 443
c.JupyterHub.ssl_key = os.environ['SSL_KEY']
c.JupyterHub.ssl_cert = os.environ['SSL_CERT']

# Persist hub data on volume mounted inside container
data_dir = os.environ.get('DATA_VOLUME_CONTAINER', '/data')

c.JupyterHub.cookie_secret_file = os.path.join(data_dir,
    'jupyterhub_cookie_secret')

c.JupyterHub.db_url = 'postgresql://postgres:{password}@{host}/{db}'.format(
    host=os.environ['POSTGRES_HOST'],
    password=os.environ['POSTGRES_PASSWORD'],
    db=os.environ['POSTGRES_DB'],
)
