ARG NOTEBOOK_BASE=jupyter/scipy-notebook:latest
FROM $NOTEBOOK_BASE

ARG NB_USER="jovyan"
ARG NB_HOME=/home/${NB_USER}

# INSTALL DOTNET
USER root
ENV \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=1 \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Ubuntu-18.04 \
    DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN sudo apt-get update
RUN sudo apt-get install -y curl

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
		-O packages-microsoft-prod.deb \ 
	&& sudo dpkg -i packages-microsoft-prod.deb \
	&& rm packages-microsoft-prod.deb

RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN sudo apt-get update
RUN sudo ACCEPT_EULA=Y apt-get install -y dotnet-sdk-3.1 curl msodbcsql17 mssql-tools unixodbc-dev


# FIX PATH ISSUE
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN dotnet tool install -g dotnet-try
RUN dotnet try jupyter install \
    && fix-permissions ${NB_HOME}

RUN npm install -g npm \
    && npm install -g tslab \
    && tslab install --python=python3

RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

RUN pip install ipython-sql \
    && pip install sqlalchemy \
    && pip install pandas \
    && pip install matplotlib \
    && pip install numpy \
    && pip install pyodbc

RUN sudo rm -rf /var/lib/apt/lists/*

# FIX Permission issue https://github.com/jupyter/notebook/issues/5058
ENV JUPYTER_RUNTIME_DIR=/tmp

USER ${NB_USER}

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]