/*==========================================================
    DATABASE : Loan Portfolio Risk Analysis
    DBMS     : PostgreSQL
    PURPOSE  : Banking Loan Portfolio & Risk Analysis
==========================================================*/

-- Data Validation Queries for Loan Portfolio Risk Analysis

-- ----------- 1. Total Record Count in Each Table ----------- --
SELECT COUNT(*) FROM loan_analysis.branch_stg;
SELECT COUNT(*) FROM loan_analysis.customer_stg;
SELECT COUNT(*) FROM loan_analysis.group_stg;
SELECT COUNT(*) FROM loan_analysis.loan_stg;
SELECT COUNT(*) FROM loan_analysis.loan_type_stg;

-- ----------- 2. Total Field Count in Each Table ----------- --
SELECT
    table_name,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'loan_analysis'
AND table_name IN (
    'branch_stg',
    'customer_stg',
    'group_stg',
    'loan_type_stg',
    'loan_stg'
)
GROUP BY table_name
ORDER BY table_name;

-- ----------- 3. Sample Data from Each Table ----------- --
SELECT * FROM loan_analysis.branch_stg LIMIT 5;

SELECT * FROM loan_analysis.customer_stg LIMIT 5;

SELECT * FROM loan_analysis.group_stg LIMIT 5;

SELECT * FROM loan_analysis.loan_type_stg LIMIT 5;

SELECT * FROM loan_analysis.loan_stg LIMIT 5;


-- ----------- 4. Check for Null Values ----------- --

-- Customer Staging table should not have null IDs or office_ids as they are essential for linking to branches and customers.

SELECT COUNT(*) AS null_ids
FROM loan_analysis.customer_stg WHERE id IS NULL;

SELECT COUNT(*) AS null_office_ids
FROM loan_analysis.customer_stg WHERE office_id IS NULL;

-- Group Staging table should not have null IDs or office_ids as they are essential for linking to branches and customers.
SELECT COUNT(*) AS null_ids
FROM loan_analysis.group_stg WHERE id IS NULL;

SELECT COUNT(*) AS null_office_ids
FROM loan_analysis.group_stg WHERE office_id IS NULL;

-- Loan Type and Loan Staging tables should not have null IDs as they are primary keys and essential for data integrity.
SELECT COUNT(*) AS null_ids
FROM loan_analysis.loan_type_stg WHERE id IS NULL;


-- Loan Staging table should not have null IDs, client_ids, or loan_product_ids as they are essential for linking to customers and loan types.
SELECT COUNT(*) AS null_ids
FROM loan_analysis.loan_stg WHERE id IS NULL;

SELECT COUNT(*) AS null_client_ids
FROM loan_analysis.loan_stg WHERE client_id IS NULL;

SELECT COUNT(*) AS null_loan_product_ids
FROM loan_analysis.loan_stg WHERE loan_product_id IS NULL;