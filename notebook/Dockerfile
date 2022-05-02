FROM nexus.ssb.no:8445/jupyter/pyspark-notebook:spark-3.2.1

USER root

# Installing R based on documentation for ubuntu https://cloud.r-project.org/
RUN apt-get update -y && \
	# install two helper packages we need 'software-properties-common && dirmngr'
	apt-get install -y --no-install-recommends "openjdk-11-jdk-headless" \
		software-properties-common dirmngr build-essential curl libssl-dev libcurl4-openssl-dev libgdal-dev && \
        
	# add the signing key (by Michael Rutter) for these repos
	# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
	# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
	wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
        
	# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
        add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
        
	# Get access 5000+ CRAN packages
        add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && \
        
	apt autoremove -y && \
	apt-get -y clean all && \
	rm -rf /var/lib/apt/lists/*

ENV R_HOME /usr/lib/R
ENV R_LIBS_USER /usr/lib/R/library

# Installing jwsacruncher, this allows users to use it directly rather than ssh to sas-servers
# DAPLA created their own version of jwsacruncher to support openjdk-11 and we are lucky to be able to use it
# https://github.com/statisticsnorway/jupyterhub-project/blob/main/docker/jupyterlab/jwsacruncher-2.2.4.zip
COPY jwsacruncher-2.2.4.zip /tmp/jwsacruncher-2.2.4.zip
RUN unzip /tmp/jwsacruncher-2.2.4.zip -d /opt && fix-permissions /opt/jwsacruncher-2.2.4 && rm -f /tmp/jwsacruncher-2.2.4.zip
RUN ln -s /opt/jwsacruncher-2.2.4/bin/jwsacruncher /usr/bin/jwsacruncher

COPY r-packages.txt /tmp/r-packages.txt

RUN apt update && \
    apt-get -y clean all && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \

    # Installing VIM
    apt-get install -y vim && \

    # Installing bsdmainutils, helped solve colrm message after every command in the terminal
    apt-get install -y bsdmainutils && \
    
    # Installing R + R packages from r-packages.txt
    xargs apt-get install -y --no-install-recommends < /tmp/r-packages.txt && \
    apt autoremove -y && \
    apt-get -y clean all

# Setup R java support and install R packages that are not available as Ubuntu packages
RUN R CMD javareconf -e && \
    R -e "install.packages('RTextTools', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('configr', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('RegSDC', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('oysteR', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('writexl', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('concaveman', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('cppRouting', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('rjwsacruncher', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('klassR', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('antiword', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('textshape', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('striprtf', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('textreadr', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('terra', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('raster', dependencies=FALSE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('leaflet', dependencies=TRUE, repos='http://cran.rstudio.com/')"

RUN R -e "remotes::install_github('r-barnes/dggridR', vignette=TRUE)" && \
    R -e "remotes::install_github('statisticsnorway/Kostra')" && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

USER $NB_UID

# TODO: python3 -m pip install --no-cache-dir -r requirements.txt
# python3 -m pip install --no-cache-dir --upgrade pip
RUN echo "**** install jupyterlab-git ****" && \
    python3 -m pip install --upgrade jupyterlab-git && \
    echo "**** install nbdime ****" && \
    python3 -m pip install --upgrade nbdime && \
    jupyter labextension install --no-build nbdime-jupyterlab && \
    echo "**** install nbstripout ****" && \
    python3 -m pip install nbstripout && \
    echo "**** install papermill ****" && \
    python3 -m pip install papermill && \
    echo "**** install ipywidgets ****" && \
    python3 -m pip install ipywidgets && \
    echo "**** install jupyter_server_proxy ****" && \
    python3 -m pip install jupyter-server-proxy && \
    echo "**** install holoviz panel ****" && \
    python3 -m pip install --upgrade pyviz_comms && \
    echo "**** install Voilà ****" && \
    python3 -m pip install voila && \
    echo "**** install Plotly ****" && \
    # JupyterLab renderer support
    python3 -m pip install plotly && \
    echo "**** install geopandas ****" && \
    python3 -m pip install geopandas && \
    echo "**** install ipyleaflet ****" && \
    python3 -m pip install ipyleaflet && \
    echo "**** install descartes ****" && \
    python3 -m pip install descartes && \
    echo "**** install jupyterlab-dash ****" && \
    python3 -m pip install jupyterlab-dash && \
    echo "**** install dash ****" && \
    python3 -m pip install jupyter-dash && \
    echo "**** install jupyter-lsp ****" && \
    python3 -m pip install jupyterlab-lsp && \
    python3 -m pip install python-language-server[all] && \
    echo "**** install ipysheet ****" && \
    python3 -m pip install ipysheet && \
    echo "**** install ipyaggrid ****" && \
    python3 -m pip install ipyaggrid && \
    echo "**** install fuzzywuzzy[speedup] ****" && \
    python3 -m pip install fuzzywuzzy[speedup] && \
    echo "**** install jupyterlab-system-monitor ****" && \
    python3 -m pip install jupyterlab-system-monitor && \
    echo "**** install jupytext ****" && \
    python3 -m pip install jupytext && \
    echo "**** uninstall IPython Parallels (comes default with dockerhub image)  ****" && \
    python3 -m pip uninstall -y ipyparallel && \
    python3 -m pip cache purge && \
    rm -rf /home/jovyan/.cache && \
    conda clean --all -y && \
    jupyter lab clean

RUN echo "**** install pipenv envkernel ****" && \
    python3 -m pip install ipykernel pipenv envkernel

# Customer defined libraries
RUN echo "**** install ssb_spark_tools ****" && \
    python3 -m pip install ssb_spark_tools==0.1.6 pytest pytest_tornasync pytest-cov pytest-mock pyjstat xmltodict lxml holidays PyGithub pre-commit pyminizip rich openpyxl && \
    echo "**** install sphinx ****" && \
    python3 -m pip install sphinx sphinx-autodoc-defaultargs sphinx-autodoc-typehints sphinx-rtd-theme && \
    echo "**** install pandas-gbq and correponding google (auth/cloud/bigquery) dependencies ****" && \
    python3 -m pip install pandas-gbq && \
    echo "**** install collapsible headers (for Jupyterlab >= 3.0) ****" && \
    python3 -m pip install aquirdturtle_collapsible_headings && \
    echo "**** install pyspark and pyarrow ****" && \
    python3 -m pip install --default-timeout=1000 pyspark pyarrow

RUN jupyter lab build --dev-build=False && \
    python3 -m pip install --upgrade jupyterhub && \
    jupyterhub upgrade-db

USER root

# Allowing usage of stamme_variabler in the terminal
# stamme_variabler is also useable in the kernels as
# the file is sourced before the kernels start
RUN ln -s /ssb/share/etc/stamme_variabel /etc/profile.d/stamme_variabel

# Copy the kernels. (pre-defined kernels are found at /opt/conda/share/jupyter/kernels)
COPY kernels/ir/kernel.json /opt/conda/share/jupyter/kernels/ir/
COPY kernels/ir/logo-64x64.png /opt/conda/share/jupyter/kernels/ir/
COPY kernels/ir/Rstartup /opt/conda/share/jupyter/kernels/ir/
COPY kernels/ir/r.sh /opt/conda/share/jupyter/kernels/ir/

COPY kernels/python3/kernel.json /opt/conda/share/jupyter/kernels/python3/
COPY kernels/python3/python.sh /opt/conda/share/jupyter/kernels/python3/
COPY kernels/python3/logo-32x32.png /opt/conda/share/jupyter/kernels/python3/
COPY kernels/python3/logo-64x64.png /opt/conda/share/jupyter/kernels/python3/

# Allowing everyone to execute python.sh and r.sh, this is done indirectly by users
RUN chmod +x /opt/conda/share/jupyter/kernels/python3/python.sh
RUN chmod +x /opt/conda/share/jupyter/kernels/ir/r.sh

COPY jupyter_notebook_extra_config.py /tmp/
RUN cat /tmp/jupyter_notebook_extra_config.py >> /etc/jupyter/jupyter_notebook_config.py && \
    rm -f /tmp/jupyter_notebook_extra_config.py

# Pip config so users install from Nexus.
RUN echo 'export PIP_INDEX="http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/pypi"' >> /etc/bash.bashrc && \
    echo 'export PIP_INDEX_URL="http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/simple"' >> /etc/bash.bashrc && \
    echo 'export PIPENV_PYPI_MIRROR="$PIP_INDEX_URL"' >> /etc/bash.bashrc && \
    echo 'export PIP_TRUSTED_HOST="pl-nexuspro-p.ssb.no"' >> /etc/bash.bashrc && \
    echo 'export PIP_REQUIRE_VIRTUALENV=true' >> /etc/bash.bashrc 

# Start up hooks
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
COPY env.sh /usr/local/bin/before-notebook.d/env.sh

USER $NB_UID
