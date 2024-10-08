ARG base_image="europe-north1-docker.pkg.dev/artifact-registry-5n/dapla-stat-docker/jupyter/jupyterlab-common:latest"
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
#    R -e "install.packages('ROracle', dependencies=TRUE, repos='https://packagemanager.rstudio.com/cran/latest')"
# ----

# Install ROracle manually from tar.gz
RUN R CMD javareconf && \
    R -e "install.packages('/tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz', repos = NULL, type='source')"

# Remove ROracle tar.gz
RUN rm -f /tmp/ROracle_1.4-1_R_x86_64-unknown-linux-gnu.tar.gz

USER $NB_UID

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
