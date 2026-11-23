from airflow import DAG
from datetime import datetime
from airflow.operators.bash import BashOperator

with DAG(
    dag_id="loan_portfolio_etl",
    start_date=datetime.today(),  # Dynamic start date
    schedule="@daily",
    catchup=False,
    tags=["etl", "loan"],
) as dag:

    run_etl = BashOperator(
        task_id="run_etl",
        bash_command="""
        echo "======================================================================"
        echo "AIRFLOW TASK STARTED : LOAN PORTFOLIO ETL"
        echo "AIRFLOW EXECUTION DATE : {{ ds }}"
        echo "AIRFLOW EXECUTION TIMESTAMP : {{ ts }}"
        echo "SYSTEM TIME : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "======================================================================"

        python /opt/airflow/project/etl/run_etl.py

        EXIT_CODE=$?

        echo ""
        echo "======================================================================"

        if [ $EXIT_CODE -eq 0 ]; then
            echo "SUCCESS : ETL PIPELINE COMPLETED"
        else
            echo "ERROR : ETL PIPELINE FAILED"
        fi

        echo "COMPLETION TIME : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "EXIT CODE : $EXIT_CODE"
        echo "======================================================================"

        exit $EXIT_CODE
        """,
    )
