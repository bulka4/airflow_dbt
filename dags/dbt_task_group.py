"""
### Run a dbt Core project as a task group with Cosmos

Simple DAG showing how to run a dbt project as a task group, using
an Airflow connection and injecting a variable into the dbt project.
"""

from airflow.decorators import dag
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig

# adjust for other database types
from pendulum import datetime
import os

YOUR_NAME = "mbulka"

# The path to the dbt project
DBT_PROJECT_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt/data_warehouse"
# The path where Cosmos will find the dbt executable
# in the virtual environment created in the Dockerfile
DBT_EXECUTABLE_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"

profile_config = ProfileConfig(
    profile_name="data_warehouse" # name of the profile in the profiles.yml file
    ,target_name="dev" # namge of the target from the profiles.yml file
    ,profiles_yml_filepath=f"{DBT_PROJECT_PATH}/profiles.yml" # path to the profiles.yml file for a dbt project
)

execution_config = ExecutionConfig(
    dbt_executable_path=DBT_EXECUTABLE_PATH
)


@dag(
    dag_id = 'dbt_task_group'
    ,start_date=datetime(2023, 8, 1)
    ,schedule=None
    ,catchup=False
    ,params={"my_name": YOUR_NAME}
)
def my_simple_dbt_dag():
    transform_data = DbtTaskGroup(
        group_id="transform_data",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        profile_config=profile_config,
        execution_config=execution_config,
        operator_args={
            "vars": '{"my_name": {{ params.my_name }} }',
        },
        default_args={"retries": 2}
        # ,select=["model_a", "model_b"],  # build specific models only
        # ,exclude=["model_to_skip"],      # exclude specific models for building
    )

    transform_data


my_simple_dbt_dag()