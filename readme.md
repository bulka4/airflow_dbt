# Introduction
This app is using Airflow and Astronomer Cosmos in order to run dbt code for performing data transformations in MS SQL server. 

In order to run the app we need to start Docker on our machine and run the command:
>docker compose up

That will run the Airflow app and also create and configure the MS SQL server.

In the below sections we can find a description of how this app works and what functionalities it provides.

## DAGs
We have here two dags:
- dbt_dag.py
- dbt_task_group.py

The dbt_dag dag creates the entire dag just for perfmorming data transformations using dbt.

The dbt_task_group dag creates a task group for perfmorming data transformations using dbt. We can use that if we want to have additional activities in our dag except for dbt.

## dbt project
dbt project with code which we will be executing in Airflow is in the dbt folder. We have defined there models, snapshots (as YAML files) and macros.

# App prerequisites
Before we run this app we need to:
- **Install Docker** - which will be running our app in containers
- **Set up a password for MS SQL server** - We do that in the dockerfiles/mssql/Dockerfile.mssql file. More info below in the 'MS SQL setup with Docker' section. Also we need to add this password to the dbt/data_warehouse/profiles.yml file like described in the 'dbt project configuration' section below.

# dbt with Airflow - materials
Materials about running dbt with Airflow:
- [www.astronomer.io](https://www.astronomer.io/docs/learn/airflow-dbt/) - Creating a task group.
- [astronomer.github.io](https://astronomer.github.io/astronomer-cosmos/getting_started/open-source.html) - Creating a dbt dag.
- [astronomer.github.io](https://astronomer.github.io/astronomer-cosmos/configuration/execution-config.html) - Configuration (for example creating execution_config).
- [astronomer.github.io](https://astronomer.github.io/astronomer-cosmos/profiles/index.html) - Creating profiles (creating profile_config).
- [youtube.com](https://www.youtube.com/watch?v=MhCuxTDlVkE) - video with overview of using Astronomer Cosmos framework for running dbt with Airflow.


# dbt project configuration
We need to add the profiles.yml file to the dbt/data_warehouse folder where we specify the database in which we will be performing data transformations. For creating that file we can use the dbt/data_warehouse/profiles-draft.yml file which is a draft of the YAML file we need to prepare. We just need to provide there a password for connecting to the MS SQL server.

In that file we need to provide the password which will be used for connecting to the created MS SQL server. We set up that password in the Dockerfile what is described in the next section of this documentation 'MS SQL setup with Docker'.

In the profiles.yml file we are also specifying a name of the ODBC driver which dbt will use to connect to the MS SQL server. That is the driver which we were installing in Airflow containers as described in the 'ODBC driver installation' section of this documentation. 


# MS SQL setup with Docker
Before running the Airflow DAG we need to create a MS SQL server and prepare there databases, schemas and tables with data which dbt will use for performing data transformations. It will be created using the 'mssql' service in the docker-compose.yml and the dockerfiles/mssql/Dockerfile.mssql file.

We need to create the Dockerfile.mssql file. For that we can use the Dockerfile-draft.mssql file, which is a draft of the Dockerfile we need to prepare. We need to provide there a password which will be used for logging into the created MS SQL server. We assign that password to the SA_PASSWORD environment variable in the Dockerfile.

In the dockerfiles/mssql folder we have two scripts needed for setting up a SQL server:
- **init.sql** - SQL script which will be executed on the created MS SQL server to create needed databases, schemas and tables with data which dbt will use to perform transformations.
- **sql_server_start.sh** - Bash script starting the MS SQL server and executing the init.sql script.



# Airflow setup with Docker
Below sections describe how containers running Airflow are prepared.

## Docker compose file
We are using here the original Docker compose file for Airflow (which we can get from here: [airflow.apache.org](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)) which we have modified slightly. The changes which we made are:
- **Use Dockerfile** - Use the dockerfiles/airflow/Dockerfile.airflow file for preparing Airflow containers. We are specifying to use that Dockerfile in the docker-compose.yaml file in the 'x-airflow-common' extension field under the 'build' property.
- **Mount the dbt folder** - We are mounting the folder with our dbt project to Airflow containers by assigning this value: 
    > '${AIRFLOW_PROJ_DIR:-.}/dbt:/opt/airflow/dbt' \

    to volumes in the 'x-airflow-common' extension field in the docker-compose.yaml file.

## ODBC driver installation
In the dockerfiles/airflow/Dockerfile.airflow file we are installing a ODBC driver which will be used by dbt to connect to the MS SQL server. 

## virtual environment for dbt
In the dockerfiles/airflow/Dockerfile.airflow file we are creating a virtual environment where we are installing dbt. We can specify which version of dbt we will use and which database adapters we want. We are creating that virtual environment in order to make sure the dbt libraries will not be in conflict with Airflow libraries.

In the Airflow DAG, using the ExecutionConfig function, we are specifying as the executable path a path from that virtual environment. That means that Airflow in order to run dbt commands (like dbt run) will use dbt executables from that virtual environment. 

## Python libraries for Airflow DAGs
In the dockerfiles/airflow/Dockerfile.airflow file we are installing all the Python libraries which we want to use in our DAGs.

Those are libraries listed in the dockerfiles/airflow/requirements.txt file. It doesn't include dbt related libraries which will be installed in a virtual environment like described in the previous section 'virtual environment for dbt'.

# powershell scripts
In the powershell_scripts folder there are powershell scripts which can be used for working with docker:
- docker_compose_up.ps1 - build and run a Docker container and save logs in the dockerfiles/docker_logs folder (that script needs to be ran from the repository root)
- docker_clean.ps1 - delete all the Docker containers and images
- sql_connect.ps1 -password <your_password> - connect to the created MS SQL server
