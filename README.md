# Jupyter notebook Docker image with dotnet, ts, mssql

## Features

- Based on [original jupyter notebook images](https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook)
- Installed [ipython-sql](https://github.com/catherinedevlin/ipython-sql) and [sqlalchemy](https://github.com/sqlalchemy/sqlalchemy)
- Installed [Microsoft ODBC driver for SQL Server](https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#17) (msodbcsql17 and mssql-tools) for conenct ipython-sql to Microsoft SQL Server
- Installed [dotnet .Core 3.1](https://dotnet.microsoft.com/download/dotnet-core/3.1) and [C# and F# kernale](https://github.com/dotnet/try)
- Installed [tslab](https://github.com/yunabe/tslab) (js and ts kernels)

## Tags:
  - **:latest** - image based on [jupyter/scipy-notebook](https://hub.docker.com/r/jupyter/scipy-notebook)
  - **:latest-full** - image based on [jupyter/all-spark-notebook
](https://hub.docker.com/r/jupyter/all-spark-notebook)
  - **:latest-minimal** - image based on [jupyter/minimal-notebook](https://hub.docker.com/r/jupyter/minimal-notebook)

 ## Getting started

```bash
docker run -d -v ./src:/home/jovyan/work -e JUPYTER_ENABLE_LAB=yes -e GRANT_SUDO=yes -p 8888:8888/tcp evg4b/jupyter-notebook-dotnet-ts-mssql:latest
```

## Connecting to mssql

For connect to mssql server use next url `mssql://<user>:<password>@<host>/<database>`

```python
In [1]: %load_ext sql
   ...:
In [2]: %%sql mssql://user1:password1@localhost/TestDatabase
   ...: select * from character
   ...: where abbrev = 'ALICE'
   ...:
Out[2]: [(u'Alice', u'Alice', u'ALICE', u'a lady attending on Princess Katherine', 22)]
```

### OR

```python
In [1]: %load_ext sql
   ...: %env DATABASE_URL= mssql://user1:password1@localhost/TestDatabase
   ...:
In [2]: %%sql select * from character where abbrev = 'ALICE'
   ...:
Out[2]: [(u'Alice', u'Alice', u'ALICE', u'a lady attending on Princess Katherine', 22)]
```

### NOTE:

Use a port connection for connect to a named server instance. For connect `database1` on server `192.23.1.55/inst1` (listen port 1443) use this connection url `mssql://user1:password1@192.23.1.55:1443/database1`