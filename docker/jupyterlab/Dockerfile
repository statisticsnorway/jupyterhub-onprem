FROM eu.gcr.io/prod-bip/ssb/statistikktjenester/jupyterlab-common:latest

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
    apt autoremove -y && \
    apt-get -y clean all

# Installing oracle-instantclient components using alien
RUN alien -i /tmp/oracle-instantclient-basic-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-devel-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-sqlplus-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-odbc-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-jdbc-21.6.0.0.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient-tools-21.6.0.0.0-1.x86_64.rpm && \
    rm -rf /tmp/oracle-instantclient-*

# add tnsnames.ora to oracle path
RUN ln -s /ssb/share/etc/tnsnames.ora /usr/lib/oracle/21/client64/lib/network/tnsnames.ora

# required to build ROracle
ENV OCI_INC /usr/include/oracle/21/client64
ENV OCI_LIB /usr/lib/oracle/21/client64/lib

# Install R packages that are not available as Ubuntu packages, and is only needed on-premises
RUN R CMD javareconf -e && \
    R -e "install.packages('ROracle', dependencies=TRUE, repos='http://cran.rstudio.com/')"


USER $NB_UID

# On-premises specific packages
RUN echo "**** install cx-Oracle ****" && \
    python3 -m pip install cx-Oracle && \
    echo "**** install Dapla tools" && \
    python3 -m pip install dapla-toolbelt==1.3.3 ssb-datadoc[gcs]==0.2.1 ssb-project-cli==1.0.7 && \
    python3 -m pip cache purge && \
    conda clean --all -y && \
    jupyter lab clean

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

COPY python-env.bash /usr/local/bin/python-env.bash
RUN chmod +x /usr/local/bin/python-env.bash
RUN ln -s /usr/local/bin/python-env.bash /usr/local/bin/python-env

# User will not be able to install packages outside of a virtual environment
ENV PIP_REQUIRE_VIRTUALENV=true

# Use proxy for https connections
ENV https_proxy=http://proxy.ssb.no:3128

USER $NB_UID
