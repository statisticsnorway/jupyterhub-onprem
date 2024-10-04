ARG base_image="jupyter/scipy-notebook@sha256:de3aa7ad8ffa02d0c461d419656503fe08c315e51a207e866f5d5edba2948f1b"
FROM ${base_image}

ARG openjdk_version="17"
ARG R_version="4.4.1-1.2204.0"

USER root

RUN apt-get update -y \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends "openjdk-${openjdk_version}-jdk-headless" ca-certificates-java \
    software-properties-common dirmngr build-essential curl libssl-dev libcurl4-openssl-dev libgdal-dev libre2-dev \
    apt-utils libudunits2-dev cmake lsb-release gpg-agent libssh-dev libsodium-dev gfortran cargo libcairo2-dev zlib1g-dev \
    # add the signing key (by Michael Rutter) for these repos
    # To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    # Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
    | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    # add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
    && add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    # Install arrow libraries, see:  \
    # https://github.com/kou/arrow-site/blob/main/install.md#c-and-glib-c-packages-for-debian-gnulinux-ubuntu-almalinux-centos-and-amazon-linux
    && wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
    && apt install -y ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
    && sudo apt update \
    && sudo apt-get install -y libfontconfig1-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev \
    libarrow-dev libarrow-glib-dev libarrow-dataset-dev libarrow-dataset-glib-dev libarrow-acero-dev libarrow-flight-dev libarrow-flight-glib-dev \
    libarrow-flight-sql-dev libarrow-flight-sql-glib-dev libgandiva-dev libgandiva-glib-dev libparquet-dev libparquet-glib-dev \    
    && add-apt-repository -y ppa:git-core/ppa \
    && gpg-agent --daemon \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt autoremove -y \
    && apt-get -y clean all \
    && rm -rf /var/lib/apt/lists/*

ENV R_HOME /usr/lib/R
ENV R_LIBS_USER /usr/lib/R/library
# https://cran.r-project.org/web/packages/arrow/vignettes/install.html
ENV NOT_CRAN true
ENV ARROW_GCS=ON



RUN apt-get update -y && \
    # Install preferred R version \
    apt-get -y install r-base=${R_version} r-recommended=${R_version} r-base-core=${R_version} r-cran-irkernel && \
    apt-mark hold r-recommended r-base r-base-core && \
    # vim support
    apt-get -y install vim && \
    # required for json parsing using bash
    apt-get -y install jq && \
    # used to find and kill files user have open
    apt-get -y install lsof && \
    # installing texlive-full
    #apt-get -y install --reinstall texlive-base tex-common texlive-full && \
    # Installing bsdmainutils, helped solve colrm message after every command in the terminal
    apt-get install -y bsdmainutils && \
    apt autoremove -y && \
    apt-get -y clean all && \
    rm -rf /var/lib/apt/lists/*

COPY jwsacruncher-2.2.4.zip /tmp/jwsacruncher-2.2.4.zip

# Setup R java support and install R packages that are not available as Ubuntu packages
RUN R CMD javareconf -e && \
    R -e "install.packages('configr', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('DBI', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('renv', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('arrow', dependencies=FALSE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('leaflet', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('getPass', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('googleCloudStorageR', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('DT', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rjwsacruncher', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('sf', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('sfarrow', dependencies=FALSE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('dbplyr', dependencies=FALSE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('shiny', dependencies=FALSE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rstudioapi', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('httr', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('readr', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('knitr', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rmarkdown', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('Rcurl', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('here', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('esquisse', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('dcmodify', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('simputation', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('SmallCountRounding', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('sparklyr', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('ggplot2', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rcurl', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('renv', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('tidyverse', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('docopt', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('smallcountrounding', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('e1071', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('easysdctable', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('pxwebapidata', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rglpk', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('remotes', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('devtools', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('units', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('ggraph', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('tidygraph', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('nabor', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rcpptoml', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('classint', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('s2', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('glmnet', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('sparsem', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('randomforest', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('tree', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('tm', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('ipred', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('catools', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('tau', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('here', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('pdftools', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('tesseract', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('sp', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('validate', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('bigrquery', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('googlecloudstorager', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rio', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('getpass', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('janitor', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('hmisc', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('arsenal', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('summarytools', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('plotly', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('oecd', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('eurostat', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('wbstats', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('countrycode', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('gargle', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('lubridate', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('haven', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('survey', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "install.packages('rjdemetra', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')" && \
    R -e "remotes::install_github('statisticsnorway/SSBpris')" && \
    R -e "remotes::install_github('statisticsnorway/GaussSuppression')" && \
    R -e "remotes::install_github('statisticsnorway/fellesr')" && \
    R -e "remotes::install_github('statisticsnorway/Kostra')" && \
    R -e "remotes::install_github('statisticsnorway/SdcForetakPerson')" && \
    R -e "remotes::install_github('statisticsnorway/struktuR')" && \
    R -e "remotes::install_github('statisticsnorway/PxWebApiData')" && \
    R -e "remotes::install_github('statisticsnorway/SSBtools')" && \
    R -e "remotes::install_github('statisticsnorway/klassR')" && \
    R -e "remotes::install_github('statisticsnorway/GISSB')" && \
    R -e "remotes::install_github('statisticsnorway/ReGenesees')" && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds && \
    # Doesn t work with Java11 - use a custom one
    #curl --silent -L -o- https://github.com/jdemetra/jwsacruncher/releases/download/v2.2.3/jwsacruncher-2.2.3-bin.zip | bsdtar -xvf- -C /opt && \
    unzip /tmp/jwsacruncher-2.2.4.zip -d /opt && fix-permissions /opt/jwsacruncher-2.2.4 && rm -f /tmp/jwsacruncher-2.2.4.zip && \
    # Create a symlink at /usr/bin so users can call jwsacruncher from anywhere
    ln -s /opt/jwsacruncher-2.2.4/bin/jwsacruncher /usr/bin/jwsacruncher



# Downloading oracle instant-client components and saving to /tmp
RUN wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-basic-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-devel-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-sqlplus-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-odbc-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-jdbc-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-tools-21.6.0.0.0-1.x86_64.rpm -P /tmp/

RUN apt update && \
    # alien is used to convert .rpms to .deb packages
    apt-get install -y alien && \
    # Installing ping
    apt-get install -y iputils-ping && \
    # libaio required by oracle 64-bit client
    apt-get install -y libaio1 libaio-dev && \
    # Install libgit2
    apt-get install -y libgit2-dev && \
    # STAT-569 - rJava issue onprem
    apt-get -y install libbz2-dev && \
    # Adding fonts required for tidyverse and other R dependencies
    apt-get install -y libfontconfig1-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev && \
    apt-get install -y libarrow-dev libarrow-glib-dev libarrow-dataset-dev libarrow-dataset-glib-dev libarrow-acero-dev libarrow-flight-dev libarrow-flight-glib-dev \
    libarrow-flight-sql-dev libarrow-flight-sql-glib-dev libgandiva-dev libgandiva-glib-dev libparquet-dev libparquet-glib-dev && \
    apt autoremove -y && \
    apt-get -y clean all

# Installing oracle-instantclient components using alien
RUN alien -i /tmp/oracle-instantclient-basic-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-devel-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-odbc-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-jdbc-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-tools-21.6.0.0.0-1.x86_64.rpm && \
    # Must install sqlplus seperately because of an issue installing using alien
    cd /tmp && \
    rpm2cpio /tmp/oracle-instantclient-sqlplus-21.6.0.0.0-1.x86_64.rpm | cpio -idmv && \
    sudo cp -r /tmp/usr/* /usr/ && \
    rm -rf /tmp/usr && \
    ldconfig && \
    rm -rf /tmp/oracle-instantclient-*

# add tnsnames.ora to oracle path
RUN ln -s /ssb/share/etc/tnsnames.ora /usr/lib/oracle/21/client64/lib/network/tnsnames.ora

# required to build ROracle
ENV OCI_INC /usr/include/oracle/21/client64
ENV OCI_LIB /usr/lib/oracle/21/client64/lib
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Copy the ROracle installation file into the container
COPY ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz /tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz

# ----
# Keeping this here because we will need to revert when ROracle has pushed fix out to the public 
#RUN R CMD javareconf && \
#    R -e "install.packages('ROracle', dependencies=TRUE, repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')"
# ----

# Install ROracle manually from tar.gz
RUN R CMD javareconf && \
    R -e "install.packages('/tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz', repos = NULL, type='source')"

# Remove ROracle tar.gz
RUN rm -f /tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz

USER $NB_UID
RUN echo "**** install pipx ****" && \
    python3 -m pip install pipx && \
    echo "**** install jupyterlab-git ****" && \
    python3 -m pip install --upgrade jupyterhub jupyterlab-git==0.44.0 && \
    echo "**** install nbdime ****" && \
    python3 -m pip install --upgrade nbdime==3.2.1 && \
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
    python3 -m pip install pyviz_comms==2.3.0 && \
    python3 -m pip install panel==0.13.1rc2 && \
    jupyter serverextension enable panel.io.jupyter_server_extension && \
    echo "**** install Plotly ****" && \
    python3 -m pip install plotly && \
    echo "**** install geopandas ****" && \
    python3 -m pip install geopandas && \
    echo "**** install ipyleaflet ****" && \
    python3 -m pip install ipyleaflet && \
    echo "**** install descartes ****" && \
    python3 -m pip install descartes && \
    echo "**** install dash ****" && \
    python3 -m pip install jupyter-dash && \
    echo "**** install jupyter-lsp ****" && \
    python3 -m pip install jupyterlab-lsp && \
    python3 -m pip install python-language-server[all] && \
    echo "**** install ipysheet ****" && \
    python3 -m pip install ipysheet && \
    echo "**** install fuzzywuzzy[speedup] ****" && \
    python3 -m pip install fuzzywuzzy[speedup] && \
    echo "**** install jupyterlab-system-monitor ****" && \
    python3 -m pip install jupyterlab-system-monitor && \
    echo "**** install jupytext ****" && \
    python3 -m pip install jupytext==1.15.2 && \
    echo "**** uninstall IPython Parallels (comes default with dockerhub image)  ****" && \
    python3 -m pip uninstall -y ipyparallel && \
    echo "**** uninstall Sympy and mpmath (comes default with dockerhub image)  ****" && \
    python3 -m pip uninstall -y sympy mpmath && \
    echo "**** install poetry ****" && \
    python3 -m pip install poetry && \
    echo "**** install sphinx ****" && \
    python3 -m pip install sphinx sphinx-autodoc-defaultargs sphinx-autodoc-typehints sphinx-rtd-theme && \
    echo "**** disable extensions which allow downloading ****" && \
    jupyter labextension disable @jupyterlab/docmanager-extension:download && \
    jupyter labextension disable @jupyterlab/filebrowser-extension:download && \
    echo "*** remove ploty/dash-jupyterlab ***" && \
    jupyter labextension uninstall @plotly/dash-jupyterlab && \
    echo "**** clean caches and finish up ****" && \
    python3 -m pip cache purge && \
    conda clean --all -y && \
    jupyter lab clean && \
    jupyter lab build --dev-build=False && \
    # Apply hot-fix for pillow.
    python3 -m pip install --upgrade pillow && \
    jupyterhub upgrade-db


# Copy the requirements.txt file into the container
COPY requirements.txt /tmp/requirements.txt

RUN echo "**** install cx-Oracle ****" && \
    python3 -m pip install cx-Oracle && \
    python3 -m pip install saspy && \
    echo "**** install Dapla tools ****" && \
    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    python3 -m pip cache purge && \
    conda clean --all -y && \
    jupyter lab clean

RUN python3 -m pip install pytest pytest_tornasync pytest-cov pytest-mock pre-commit-hooks jupyterlab-code-formatter black[jupyter] isort && \
python3 -m pip install pyjstat xmltodict lxml holidays PyGithub pre-commit pyminizip rich openpyxl pyarrow python-dotenv poetry && \
python3 -m pip cache purge

RUN jupyter labextension disable @jupyterlab/extensionmanager-extension

# Set template version for ssb-project-cli (https://github.com/statisticsnorway/ssb-project-template-stat)
ENV STAT_TEMPLATE_DEFAULT_REFERENCE="1.1.7"

# required by dapla team cli
ENV DAPLA_TEAM_API_BASE_URL="http://dapla-team-api.dapla.svc.cluster.local/"

USER root

# Set localtime to Europe/Oslo
RUN rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/Europe/Oslo /etc/localtime

# Installing quarto https://quarto.org/
# not installing .deb file because some features don't work
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.340/quarto-1.3.340-linux-amd64.tar.gz -P /tmp/ && \
    tar -zxf /tmp/quarto-1.3.340-linux-amd64.tar.gz -C /usr/local/ && \
    ln -s /usr/local/quarto-1.3.340/bin/quarto /usr/local/bin/quarto && \
    rm -rf /tmp/quarto-1.3.340-linux-amd64.tar.gz

# adding a custom bashrc with git branch in PS1
COPY common-bashrc /etc/skel/.bashrc
# Set common codestyle settings and update old users with possible new files from /etc/skel
RUN mkdir /etc/skel/.config && \
    mkdir -p /usr/local/bin/before-notebook.d && \
    echo 'tar -cf - -C /etc/skel . | tar --skip-old-files --directory /home/jovyan -xf -' \
    >  /usr/local/bin/before-notebook.d/sync-skel.sh && \
    chmod +x /usr/local/bin/before-notebook.d/sync-skel.sh

COPY common-pycodestyle /etc/skel/.config/pycodestyle

# Install ssb_gitconfig.py script
RUN wget -O /usr/local/bin/ssb_gitconfig.py https://raw.githubusercontent.com/statisticsnorway/kvakk-git-tools/main/kvakk_git_tools/ssb_gitconfig.py
RUN chmod +x /usr/local/bin/ssb_gitconfig.py

# Install ssb_gitconfig.py script
RUN wget -O /usr/local/bin/ssb_gitconfig.py https://raw.githubusercontent.com/statisticsnorway/kvakk-git-tools/main/kvakk_git_tools/ssb_gitconfig.py
RUN chmod +x /usr/local/bin/ssb_gitconfig.py

COPY check-git-config.bash /usr/local/bin/check-git-config.sh
RUN chmod +x /usr/local/bin/check-git-config.sh

COPY jupyter_notebook_extra_config.py /tmp/
RUN cat /tmp/jupyter_notebook_extra_config.py >> /etc/jupyter/jupyter_server_config.py && \
    # Remove support for legacy Notebook Server, see https://github.com/jupyter/docker-stacks/blob/main/base-notebook/Dockerfile#L64
    rm /etc/jupyter/jupyter_notebook_config.py && \
    chmod g-w /etc/jupyter/*.py && \
    rm -f /tmp/jupyter_notebook_extra_config.py

# Remove duplicate Python lib
RUN rm /usr/bin/python3 && ln -s /opt/conda/bin/python3 /usr/bin/python3

#Prevent installation of extentions, by removing write privilege in extension folders.
RUN chmod u-w  /opt/conda/share/jupyter/labextensions
RUN chmod u-w  /opt/conda/share/jupyter/nbextensions
RUN chmod u-w  /opt/conda/share/jupyter/lab/extensions

# Allowing usage of stamme_variabler in the terminal
# stamme_variabler is also useable in the kernels as
# the file is sourced before the kernels start
RUN ln -s /ssb/share/etc/stamme_variabel /etc/profile.d/stamme_variabel

RUN mkdir -p /usr/local/share/etc/
COPY bashrc.felles /usr/local/share/etc/bashrc.felles

# Copy the kernels. (pre-defined kernels are found at /opt/conda/share/jupyter/kernels)
COPY kernels/ir /opt/conda/share/jupyter/kernels/ir/
COPY kernels/python3 /opt/conda/share/jupyter/kernels/python3/

# Allowing everyone to execute python.sh and r.sh, this is done indirectly by users
RUN chmod +x /opt/conda/share/jupyter/kernels/python3/python.sh
RUN chmod +x /opt/conda/share/jupyter/kernels/ir/r.sh

# Change default R repo
COPY Rprofile.site /etc/R/Rprofile.site

# User will not be able to install packages outside of a virtual environment
ENV PIP_REQUIRE_VIRTUALENV=true

# Setting up environment variables for pip and pipenv
# Pip config so users install from Nexus.
ENV PIP_INDEX=http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/pypi
ENV PIP_INDEX_URL=http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/simple
ENV PIPENV_PYPI_MIRROR=$PIP_INDEX_URL
ENV PIP_TRUSTED_HOST=pl-nexuspro-p.ssb.no
RUN pip config set global.index http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/pypi --global && \
    pip config set global.index-url http://pl-nexuspro-p.ssb.no:8081/repository/pypi-proxy/simple --global && \
    pip config set global.trusted-host pl-nexuspro-p.ssb.no --global

# Use proxy for https connections
ENV https_proxy=http://proxy.ssb.no:3128
ENV no_proxy=nexus.ssb.no,git-adm.ssb.no,i.test.ssb.no,i.ssb.no,i.qa.ssb.no,data.ssb.no,github.com,api.github.com,codeload.github.com

# Pull and update ca-certificates
RUN mkdir "/usr/local/bin/start-notebook.d" && \
    echo "curl https://nexus.ssb.no/repository/certificate_repo/ssb/cert_Decrypt-CA.crt --output /usr/local/share/ca-certificates/cert_Decrypt-CA.crt" > /usr/local/bin/start-notebook.d/update-certificate.sh && \
    echo "update-ca-certificates" >> /usr/local/bin/start-notebook.d/update-certificate.sh && \
    chmod +x /usr/local/bin/start-notebook.d/update-certificate.sh

# Set FELLES environment variable
ENV FELLES=/ssb/bruker/felles
ENV ARROW_THIRDPARTY_DEPENDENCY_DIR=$FELLES/R_pakker/arrow
ENV ARROW_GCS=OFF
ENV ARROW_S3=OFF

# Adding pythonForSsb in PYTHONPATH
ENV PYTHONPATH=$PYTHONPATH:/ssb/bruker/felles/pythonForSsb

# Setting up environment variables for oracle
ENV OCI_INC=/usr/include/oracle/21/client64
ENV OCI_LIB=/usr/lib/oracle/21/client64/lib
ENV ORACLE_HOME=/usr/lib/oracle/21/client64
ENV TNS_ADMIN=/usr/lib/oracle/21/client64/lib/network
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/21/client64/lib

# Add conda lib to LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/conda/lib
# Set Dapla environment variables used to identify the service.
ENV DAPLA_SERVICE=JUPYTERLAB
ENV DAPLA_REGION=ON_PREM

USER $NB_UID