# Locking ourselves to this base_image to avoid breaking changes in the future
ARG base_image="europe-north1-docker.pkg.dev/artifact-registry-5n/dapla-stat-docker/jupyter/jupyterlab-common@sha256:0221fabe6d88704ab1396852cdfe224887b8ba0893577ba7d007b0cfd5c2b621"
FROM ${base_image}

USER root

ENV R_HOME /usr/lib/R
ENV R_LIBS_USER /usr/lib/R/library

# Downloading oracle instant-client components and saving to /tmp
RUN wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-basic-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-devel-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-sqlplus-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-odbc-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-jdbc-21.6.0.0.0-1.x86_64.rpm -P /tmp/ && \
    wget https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-tools-21.6.0.0.0-1.x86_64.rpm -P /tmp/

ARG libarrow_version="18.1.0"

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
    apt-get purge -y libarrow-dev libarrow-glib-dev libarrow-dataset-dev libarrow-dataset-glib-dev libarrow-acero-dev libarrow-flight-dev libarrow-flight-glib-dev \
    libarrow-flight-sql-dev libarrow-flight-sql-glib-dev libgandiva-dev libgandiva-glib-dev libparquet-dev libparquet-glib-dev && \
    # installing libarrow with a dynamic version
    apt-get install -y libarrow-dev=${libarrow_version}-1 libarrow-glib-dev=${libarrow_version}-1 libarrow-dataset-dev=${libarrow_version}-1 \ 
    libarrow-dataset-glib-dev=${libarrow_version}-1 libarrow-acero-dev=${libarrow_version}-1 libarrow-flight-dev=${libarrow_version}-1 \ 
    libarrow-flight-glib-dev=${libarrow_version}-1 libarrow-flight-sql-dev=${libarrow_version}-1 libarrow-flight-sql-glib-dev=${libarrow_version}-1 \ 
    gir1.2-arrow-dataset-1.0=${libarrow_version}-1 gir1.2-arrow-flight-1.0=${libarrow_version}-1 gir1.2-arrow-flight-sql-1.0=${libarrow_version}-1 \ 
    gir1.2-arrow-1.0=${libarrow_version}-1 gir1.2-gandiva-1.0=${libarrow_version}-1 gir1.2-parquet-1.0=${libarrow_version}-1   \ 
    libgandiva-dev=${libarrow_version}-1 libgandiva-glib-dev=${libarrow_version}-1 libparquet-dev=${libarrow_version}-1 libparquet-glib-dev=${libarrow_version}-1 && \
    apt autoremove -y && \
    apt-get -y clean all
    

# Installing this dependency for having igraph, Rglpk, pdftools and V8
RUN apt-get install -y libopenblas-dev libglpk-dev libpoppler-cpp-dev libv8-dev libnode-dev


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
#    R -e "install.packages('ROracle', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')"
# ----

# Install ROracle manually from tar.gz
RUN R CMD javareconf && \
    R -e "install.packages('/tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz', repos = NULL, type='source')"

# Remove ROracle tar.gz
RUN rm -f /tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz

USER root
# install ipydatagrid for python via pip as root
RUN python3 -m pip install ipydatagrid


# Running this to update and add packages from last push
RUN R -e "install.packages('tidyfst', repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('configr', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('DBI', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('renv', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('arrow', dependencies=FALSE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('leaflet', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('getPass', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('googleCloudStorageR', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('DT', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('rjwsacruncher', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('sf', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('sfarrow', dependencies=FALSE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('dbplyr', dependencies=FALSE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('shiny', dependencies=FALSE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('rstudioapi', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('httr', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('readr', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('knitr', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('rmarkdown', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('Rcurl', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('here', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('esquisse', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('dcmodify', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('simputation', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('SmallCountRounding', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('klassR', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('pxwebapidata', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "install.packages('gissb', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-pris')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-gausssuppression')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-fellesr')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-kostra')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-SdcForetakPerson')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-struktuR')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-SSBtools')" && \
    R -e "remotes::install_github('statisticsnorway/ReGenesees')" && \
    R -e "install.packages('igraph', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')" && \
    R -e "remotes::install_github('statisticsnorway/ssb-pickmdl')" && \
    R -e "install.packages('dggridR', repos='https://packagemanager.rstudio.com/cran/latest')"

USER $NB_UID

# Copy the requirements.txt file into the container
COPY requirements.txt /tmp/requirements.txt

RUN echo "**** install cx-Oracle ****" && \
    python3 -m pip install cx-Oracle && \
    python3 -m pip install saspy && \
    echo "**** install Dapla tools ****" && \
    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    echo "**** install Poetry shell ****" && \
    python3 -m pip install poetry-plugin-shell && \
    echo "**** install nox poetry ****" && \
    python3 -m pip install nox-poetry && \
    echo "**** install nox ****" && \
    python3 -m pip install nox && \
    python3 -m pip cache purge && \
    conda clean --all -y && \
    jupyter lab clean

# Set template version for ssb-project-cli (https://github.com/statisticsnorway/ssb-project-template-stat)
ENV STAT_TEMPLATE_DEFAULT_REFERENCE="1.1.7"

# required by dapla team cli
ENV DAPLA_TEAM_API_BASE_URL="http://dapla-team-api.dapla.svc.cluster.local/"

USER root

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
ENV PIP_INDEX=https://pypi.org/pypi
ENV PIP_INDEX_URL=https://pypi.org/simple
ENV PIPENV_PYPI_MIRROR=$PIP_INDEX_URL
ENV PIP_TRUSTED_HOST=pypi.org
RUN pip config set global.index https://pypi.org/pypi --global && \
    pip config set global.index-url https://pypi.org/simple --global && \
    pip config set global.trusted-host pypi.org --global

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

# Set Dapla environment variables used to identify the service.
ENV DAPLA_SERVICE=JUPYTERLAB
ENV DAPLA_REGION=ON_PREM

USER $NB_UID
