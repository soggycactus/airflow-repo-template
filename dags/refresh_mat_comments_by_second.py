import airflow
from airflow.operators.bash_operator import BashOperator
from airflow.models import DAG

args = {
    'owner': 'Freddy Drennan',
    'start_date': airflow.utils.dates.days_ago(2),
    'email': ['drennanfreddy@gmail.com'],
    'retries': 100,
    'email_on_failure': True,
    'email_on_retry': True
}
dag = DAG(dag_id='refresh_mat_comments_by_second',
          default_args=args,
          schedule_interval='*/5 * * * *',
          concurrency=1,
          max_active_runs=1,
          catchup=False)

task_1 = BashOperator(
    task_id='refresh_mat_comments_by_second',
    bash_command='. /home/scripts/R/shell/refresh_mat_comments_by_second',
    dag=dag
)

