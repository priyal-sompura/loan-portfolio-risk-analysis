/*==========================================================
    FOREIGN KEY CONSTRAINTS
    PROJECT : Loan Portfolio Risk Analysis
    DBMS    : PostgreSQL
==========================================================*/

/* Note:
    fk_branch_parent was not created because the root branch uses parent_id = 0.
    No corresponding branch record exists with id = 0, causing FK validation to fail.
    The value 0 is treated as a business indicator for the Head Office/Root Branch.
    Therefore, the original hierarchy was preserved and the constraint was intentionally omitted.
*/

-- fk_customer_branch
-- Links customers to their registered branch.

ALTER TABLE loan_analysis.customer_tb
ADD CONSTRAINT fk_customer_branch
FOREIGN KEY (office_id)
REFERENCES loan_analysis.branch_tb(id);


-- fk_customer_transfer_branch
-- Links customers to their transferred branch.

ALTER TABLE loan_analysis.customer_tb
ADD CONSTRAINT fk_customer_transfer_branch
FOREIGN KEY (transfer_to_office_id)
REFERENCES loan_analysis.branch_tb(id);


-- fk_group_branch
-- Links customer groups to their managing branch.

ALTER TABLE loan_analysis.group_tb
ADD CONSTRAINT fk_group_branch
FOREIGN KEY (office_id)
REFERENCES loan_analysis.branch_tb(id);


-- fk_group_parent
-- Supports parent-child hierarchy among groups.

ALTER TABLE loan_analysis.group_tb
ADD CONSTRAINT fk_group_parent
FOREIGN KEY (parent_id)
REFERENCES loan_analysis.group_tb(id);


-- fk_loan_customer
-- Links loans to customers.

ALTER TABLE loan_analysis.total_loan_tb
ADD CONSTRAINT fk_loan_customer
FOREIGN KEY (client_id)
REFERENCES loan_analysis.customer_tb(id);


-- fk_loan_group
-- Links loans to customer groups.

ALTER TABLE loan_analysis.total_loan_tb
ADD CONSTRAINT fk_loan_group
FOREIGN KEY (group_id)
REFERENCES loan_analysis.group_tb(id);


-- fk_loan_product
-- Links loans to loan products/types.

ALTER TABLE loan_analysis.total_loan_tb
ADD CONSTRAINT fk_loan_product
FOREIGN KEY (product_id)
REFERENCES loan_analysis.loan_type_tb(id);


-- VERIFY ALL FOREIGN KEY CONSTRAINTS

SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'loan_analysis'
ORDER BY tc.table_name;