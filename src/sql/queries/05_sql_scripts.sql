SET search_path TO loan_analysis;

-- Insight: Total Loan Portfolio Value (Principal Disbursed)
SELECT
    COUNT(*) AS total_loans,
    SUM(principal_amount) AS total_principal_disbursed,
    SUM(principal_outstanding_derived) AS current_outstanding,
    ROUND(
        (SUM(principal_outstanding_derived) * 100.0 / NULLIF(SUM(principal_amount), 0))::numeric, 
    2) AS recovery_percentage,
    SUM(CASE WHEN is_npa = TRUE THEN principal_outstanding_derived ELSE 0 END) AS total_npa_amount
FROM loan_stg;


-- Insight: Top 20 Loans with Highest Outstanding Amount
SELECT
    id AS loan_id,
    account_no,
    principal_outstanding_derived AS outstanding_amount,
    principal_amount AS original_principal,
    disbursedon_date,
    maturedon_date,
    is_npa
FROM loan_stg
ORDER BY principal_outstanding_derived DESC
LIMIT 20;


-- Insight: Loan count and total outstanding by Loan Status
SELECT
    loan_status_id,
    COUNT(*) AS loan_count,
    SUM(principal_outstanding_derived) AS total_outstanding,
    ROUND(
        (SUM(principal_outstanding_derived) * 100.0 / NULLIF(SUM(principal_amount), 0))::numeric, 
    2) AS outstanding_ratio
FROM loan_stg
GROUP BY loan_status_id
ORDER BY total_outstanding DESC;


-- Insight: Branch-wise customer and loan summary
SELECT
    b.office_code,
    COUNT(DISTINCT c.id) AS total_customers,
    COUNT(DISTINCT l.id) AS total_loans,
    SUM(l.principal_outstanding_derived) AS total_outstanding
FROM branch_stg b
LEFT JOIN customer_stg c ON b.id = c.office_id
LEFT JOIN loan_stg l ON c.id = l.client_id
GROUP BY b.office_code
ORDER BY total_outstanding DESC;


-- Insight: Most Active Branches (Only branches having customers)
SELECT
    b.office_code,
    COUNT(DISTINCT c.id) AS total_customers,
    COUNT(DISTINCT l.id) AS total_loans,
    SUM(l.principal_outstanding_derived) AS total_outstanding,
    ROUND(AVG(l.principal_outstanding_derived)::numeric, 2) AS avg_loan_outstanding
FROM branch_stg b
LEFT JOIN customer_stg c ON b.id = c.office_id
LEFT JOIN loan_stg l ON c.id = l.client_id
GROUP BY b.office_code
HAVING COUNT(DISTINCT c.id) > 0
ORDER BY total_outstanding DESC;


-- Insight: Complete 360-degree view of each loan (Customer + Branch + Product)
SELECT
    l.id AS loan_id,
    l.account_no AS loan_account,
    c.account_no AS customer_account,
    b.office_code AS branch_code,
    lt.id AS product_id,
    l.principal_amount,
    l.principal_outstanding_derived AS outstanding_amount,
    l.is_npa,
    l.disbursedon_date,
    l.maturedon_date
FROM loan_stg l
INNER JOIN customer_stg c ON l.client_id = c.id
INNER JOIN branch_stg b ON c.office_id = b.id
INNER JOIN loan_type_stg lt ON l.product_id = lt.id
WHERE l.disbursedon_date IS NOT NULL
ORDER BY l.principal_outstanding_derived DESC
LIMIT 20;


-- Insight: Detailed branch-wise portfolio view with NPA percentage
SELECT
    b.id AS branch_id,
    b.office_code,
    b.is_fieldoffice,
    COUNT(DISTINCT c.id) AS total_customers,
    COUNT(DISTINCT l.id) AS total_loans,
    COALESCE(SUM(l.principal_outstanding_derived), 0) AS total_outstanding_amount,
    COALESCE(SUM(CASE WHEN l.is_npa = TRUE THEN l.principal_outstanding_derived ELSE 0 END), 0) AS npa_amount,
    CASE
        WHEN COALESCE(SUM(l.principal_outstanding_derived), 0) = 0 THEN 0.00
        ELSE ROUND(
            (SUM(CASE WHEN l.is_npa = TRUE THEN l.principal_outstanding_derived ELSE 0 END) * 100.0 
             / SUM(l.principal_outstanding_derived))::numeric, 2)
    END AS npa_percentage
FROM branch_stg b
LEFT JOIN customer_stg c ON b.id = c.office_id
LEFT JOIN loan_stg l ON c.id = l.client_id
GROUP BY b.id, b.office_code, b.is_fieldoffice
ORDER BY total_outstanding_amount DESC, total_customers DESC;