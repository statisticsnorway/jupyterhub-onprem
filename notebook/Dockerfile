FROM nexus.ssb.no:8445/jupyter/pyspark-notebook:spark-3.2.1

USER root

RUN apt-get update -y && \
	apt-get install -y --no-install-recommends "openjdk-11-jdk-headless" \
		software-properties-common dirmngr build-essential curl libssl-dev libcurl4-openssl-dev libgdal-dev && \
	# bsdmainutils helped solve colrm message after every command in the terminal
        apt-get install -y bsdmainutils && \
        apt autoremove -y && \
	apt-get -y clean all && \
	rm -rf /var/lib/apt/lists/*

# Installing jwsacruncher, this allows users to use it directly rather than ssh to sas-servers
# DAPLA created their own version of jwsacruncher to support openjdk-11 and we are lucky to be able to use it
# https://github.com/statisticsnorway/jupyterhub-project/blob/main/docker/jupyterlab/jwsacruncher-2.2.4.zip
COPY jwsacruncher-2.2.4.zip /tmp/jwsacruncher-2.2.4.zip
RUN unzip /tmp/jwsacruncher-2.2.4.zip -d /opt && fix-permissions /opt/jwsacruncher-2.2.4 && rm -f /tmp/jwsacruncher-2.2.4.zip
RUN ln -s /opt/jwsacruncher-2.2.4/bin/jwsacruncher /usr/bin/jwsacruncher

RUN apt update && \
    apt-get -y clean all && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get install -y vim && \
    apt autoremove -y && \
    apt-get -y clean all

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
    #echo "**** install streamlit ****" && \
    #showstopper: https://github.com/streamlit/streamlit/issues/2703
    #python3 -m pip install streamlit && \
    echo "**** install jupyter-lsp ****" && \
    python3 -m pip install jupyterlab-lsp && \
    python3 -m pip install python-language-server[all] && \
    echo "**** install ipysheet ****" && \
    python3 -m pip install ipysheet && \
    echo "**** install ipyaggrid ****" && \
    python3 -m pip install ipyaggrid && \
    #echo "**** install qgrid ****" && \
    #showstopper: https://github.com/quantopian/qgrid/issues/350
    #python3 -m pip install qgrid2 && \
    echo "**** install fuzzywuzzy[speedup] ****" && \
    python3 -m pip install fuzzywuzzy[speedup] && \
    echo "**** install jupyterlab-system-monitor ****" && \
    python3 -m pip install jupyterlab-system-monitor && \
    echo "**** install jupytext ****" && \
    python3 -m pip install jupytext && \
    #jupyter labextension install --no-build jupyterlab-jupytext && \
    echo "**** uninstall IPython Parallels (comes default with dockerhub image)  ****" && \
    python3 -m pip uninstall -y ipyparallel && \
    python3 -m pip cache purge && \
    rm -rf /home/jovyan/.cache && \
    conda clean --all -y && \
    jupyter lab clean

RUN echo "**** install pipenv envkernel ****" && \
    python3 -m pip install ipykernel pipenv envkernel

RUN jupyter lab build --dev-build=False && \
    python3 -m pip install --upgrade jupyterhub && \
    jupyterhub upgrade-db

USER root

COPY jupyter_notebook_extra_config.py /tmp/
RUN cat /tmp/jupyter_notebook_extra_config.py >> /etc/jupyter/jupyter_notebook_config.py && \
    rm -f /tmp/jupyter_notebook_extra_config.py && \
    fix-permissions /usr/local/spark/conf

# Start up hooks
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
COPY env.sh /usr/local/bin/before-notebook.d/env.sh

USER $NB_UID
