from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping
from pendulum import datetime
import os

DBT_PROJECT_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt/data_warehouse"

profile_config = ProfileConfig(
    profile_name="data_warehouse" # name of the profile in the profiles.yml file
    ,target_name="dev" # namge of the target from the profiles.yml file
    ,profiles_yml_filepath=f"{DBT_PROJECT_PATH}/profiles.yml" # path to the profiles.yml file for a dbt project
)

my_cosmos_dag = DbtDag(
    project_config=ProjectConfig(DBT_PROJECT_PATH),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
    ),
    # normal dag parameters
    schedule_interval="@daily",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="dbt_dag",
    default_args={"retries": 2},
)
