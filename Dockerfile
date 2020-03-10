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
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Ubuntu-18.04

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
		-O packages-microsoft-prod.deb \ 
	&& sudo dpkg -i packages-microsoft-prod.deb \
	&& rm packages-microsoft-prod.deb

RUN sudo apt-get update \
	&& sudo apt-get install -y dotnet-sdk-3.1 \
	&& dotnet help \
    && rm -rf /var/lib/apt/lists/*

RUN dotnet tool install -g dotnet-try

ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN dotnet try jupyter install \
    && fix-permissions ${NB_HOME}

# INSTALL TSLAB

RUN npm install -g npm && npm install -g tslab && tslab install --python=python3

RUN sudo apt-get update
RUN sudo apt-get install curl -y
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/19.10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN sudo apt-get update
RUN sudo ACCEPT_EULA=Y apt-get -y install msodbcsql17
# optional: for bcp and sqlcmd
RUN sudo ACCEPT_EULA=Y apt-get install mssql-tools  -y
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
# RUN source ~/.bashrc
# optional: for unixODBC development headers
# RUN sudo apt-get install unixodbc-dev
RUN sudo apt-get install unixodbc-dev -y

RUN pip install ipython-sql
RUN pip install sqlalchemy
RUN pip install pandas
RUN pip install matplotlib
RUN pip install numpy	
RUN pip install pyodbc

USER ${NB_USER}

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]