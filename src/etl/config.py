"""
=============================================================
    CONFIG — Loan Portfolio Risk Analysis
    File   : etl/config.py
    ✏️  Fill in DB_CONFIG before running.
=============================================================
"""

DB_CONFIG = {
    "user": "postgres",
    "password": "root",
    "host": "172.18.64.1",
    "port": "5432",
    "dbname": "loan_portfolio_db",
}

SCHEMA = "loan_analysis"
MART_SCHEMA = "reporting"  # data mart / Power BI layer

SOURCE_TABLES = {
    "branch": "branch_tb",
    "customer": "customer_tb",
    "group": "group_tb",
    "loan_type": "loan_type_tb",
    "loan": "total_loan_tb",
}

STAGING_MAP = {
    "branch": "branch_stg",
    "customer": "customer_stg",
    "group": "group_stg",
    "loan_type": "loan_type_stg",
    "loan": "loan_stg",
}

# Parent → child order used for loading and constraint application
TABLE_ORDER = ["branch", "customer", "group", "loan_type", "loan"]

# Data mart views (50 cols total across 4 objects)
MART_VIEWS = ["dim_branch", "dim_customer", "dim_loan_product", "fact_loan_portfolio"]
