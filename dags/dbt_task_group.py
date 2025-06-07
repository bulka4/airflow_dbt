"""
### Run a dbt Core project as a task group with Cosmos

Simple DAG showing how to run a dbt project as a task group, using
an Airflow connection and injecting a variable into the dbt project.
"""

# from airflow.decorators import dag
from airflow import DAG
from airflow.decorators import task
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig, RenderConfig

# adjust for other database types
# from pendulum import datetime
from datetime import datetime
import os


@task(task_id="data_ingestion")
def data_ingestion():
    print('ingesting data to the MS SQL server from external sources')

@task(task_id="dashboard_refresh")
def dashboard_refresh():
    print('Refreshing dashboard')


YOUR_NAME = "mbulka"

# The path to the dbt project
DBT_PROJECT_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt/data_warehouse"
# The path where Cosmos will find the dbt executable. That is the
# virtual environment created in the Dockerfile.
DBT_EXECUTABLE_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"

profile_config = ProfileConfig(
    profile_name="data_warehouse" # name of the profile in the profiles.yml file
    ,target_name="dev" # namge of the target from the profiles.yml file
    ,profiles_yml_filepath=f"{DBT_PROJECT_PATH}/profiles.yml" # path to the profiles.yml file for a dbt project
)

execution_config = ExecutionConfig(
    dbt_executable_path=DBT_EXECUTABLE_PATH
)

with DAG(
    dag_id = 'dbt_task_group'
    ,start_date = datetime.now()
    ,schedule_interval = None # '@hourly'
    ,catchup = False
    ,params={"my_name": YOUR_NAME}
) as dag:
    # task group for building snapshots
    snapshots = DbtTaskGroup(
        group_id="snapshots"
        ,project_config=ProjectConfig(DBT_PROJECT_PATH)
        ,profile_config=profile_config
        ,execution_config=execution_config
        ,render_config=RenderConfig(select=["path:snapshots"]) # build only snapshots using dbt node selector
        ,operator_args={
            "vars": '{"my_name": {{ params.my_name }} }' # pass variables to the dbt command, like 'dbt run --vars'
        }
        ,default_args={"retries": 2}
    )

    # task group for testing source data
    test_sources = DbtTaskGroup(
        group_id="test_sources"
        ,project_config=ProjectConfig(DBT_PROJECT_PATH)
        ,profile_config=profile_config
        ,execution_config=execution_config
        ,render_config=RenderConfig(
            select=["source:*"] # perform tests only on a source data using dbt node selector.
            # We need to include the below argument because otherwise source nodes will be not rendered 
            # (there will not be any tasks in Airflow DAG for them).
            ,source_rendering_behavior="with_tests_or_freshness"
            # This argument makes sure that when we have models dependent on each other, then we will not run
            # the same tests twice and we will run them only when all the models included in that test have been built.
            ,should_detach_multiple_parents_tests=True
        )
        ,operator_args={
            "vars": '{"my_name": {{ params.my_name }} }' # pass variables to the dbt command, like 'dbt run --vars'
        }
        ,default_args={"retries": 2}
    )

    # task group for building and testing models
    transform_and_test_data = DbtTaskGroup(
        group_id="transform_and_test_data"
        ,project_config=ProjectConfig(DBT_PROJECT_PATH)
        ,profile_config=profile_config
        ,execution_config=execution_config
        ,render_config=RenderConfig(
            select=["path:models"]  # build only models using dbt node selector.
            ,exclude=["source:*"] # don't perform tests on the source tables (exclude them like with the --exclude flag in dbt commands).
            # This argument makes sure that when we have models dependent on each other, then we will not run
            # the same tests twice and we will run them only when all the models included in that test have been built.
            ,should_detach_multiple_parents_tests=True
        )
        ,operator_args={
            "vars": '{"my_name": {{ params.my_name }} }' # pass variables to the dbt command, like 'dbt run --vars'
        }
        ,default_args={"retries": 2}
    )
    
    data_ingestion() >> snapshots >> test_sources >> transform_and_test_data >> dashboard_refresh()