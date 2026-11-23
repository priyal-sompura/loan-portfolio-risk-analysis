/*=------------------------------=
    DATABASE : Loan Portfolio Risk Analysis
    DBMS     : PostgreSQL
    PURPOSE  : Banking Loan Portfolio & Risk Analysis
------------------------------=*/

-- Data Loading Queries for Loan Portfolio Risk Analysis

/*=------------------------------
    LOAD BRANCH DATA INTO POSTGRESQL TABLE
    Source: branch_data.csv
------------------------------=*/

COPY loan_analysis.branch_tb
FROM 'C:/Program Files/PostgreSQL/17/data/datasets/bank_st/branch_data.csv'
DELIMITER ','
CSV HEADER
NULL ''
ENCODING 'UTF8';

-- Preview branch records
SELECT *
FROM loan_analysis.branch_tb;

-- Validate total number of branch records loaded
SELECT COUNT(*) AS total_branches
FROM loan_analysis.branch_tb;


/*=------------------------------
    LOAD CUSTOMER DATA INTO POSTGRESQL TABLE
    Source: customer_data.csv
    ------------------------------=*/

COPY loan_analysis.customer_tb
FROM 'C:/Program Files/PostgreSQL/17/data/datasets/bank_st/customer_data.csv'
DELIMITER ','
CSV HEADER
NULL ''
ENCODING 'UTF8';

-- Preview customer records
SELECT *
FROM loan_analysis.customer_tb;

-- Validate total number of customer records loaded
SELECT COUNT(*) AS total_customers
FROM loan_analysis.customer_tb;


/*=------------------------------
    LOAD GROUP DETAILS DATA INTO POSTGRESQL TABLE
    Source: group_details_data.csv
------------------------------=*/

COPY loan_analysis.group_tb
FROM 'C:/Program Files/PostgreSQL/17/data/datasets/bank_st/group_details_data.csv'
DELIMITER ','
CSV HEADER
NULL ''
ENCODING 'UTF8';

-- Preview group records
SELECT *
FROM loan_analysis.group_tb;

-- Validate total number of group records loaded
SELECT COUNT(*) AS total_groups
FROM loan_analysis.group_tb;


/*=------------------------------
    LOAD LOAN PRODUCT DATA INTO POSTGRESQL TABLE
    Source: loan_type_data.csv
------------------------------=*/

COPY loan_analysis.loan_type_tb
FROM 'C:/Program Files/PostgreSQL/17/data/datasets/bank_st/loan_type_data.csv'
DELIMITER ','
CSV HEADER
NULL ''
ENCODING 'UTF8';

-- Preview loan product records
SELECT *
FROM loan_analysis.loan_type_tb;

-- Validate total number of loan products loaded
SELECT COUNT(*) AS total_loan_products
FROM loan_analysis.loan_type_tb;


/*=------------------------------
    LOAD LOAN PORTFOLIO DATA INTO POSTGRESQL TABLE
    Source: total_loan_data.csv
------------------------------=*/

COPY loan_analysis.total_loan_tb
FROM 'C:/Program Files/PostgreSQL/17/data/datasets/bank_st/total_loan_data.csv'
DELIMITER ','
CSV HEADER
NULL ''
ENCODING 'UTF8';

-- Preview loan records
SELECT *
FROM loan_analysis.total_loan_tb;

-- Validate total number of loan records loaded
SELECT COUNT(*) AS total_loans
FROM loan_analysis.total_loan_tb;
