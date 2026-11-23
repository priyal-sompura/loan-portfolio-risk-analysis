SET search_path TO loan_analysis;


CREATE OR REPLACE VIEW loan_view AS

SELECT

    -- Keys
    id AS loan_id,
    client_id,
    group_id,
    product_id,
    loan_officer_id,

    -- Status
    loan_status_id,

    CASE loan_status_id
        WHEN 100 THEN 'Submitted'
        WHEN 300 THEN 'Approved'
        WHEN 500 THEN 'Approved'
        WHEN 600 THEN 'Closed'
        WHEN 601 THEN 'Withdrawn'
        WHEN 602 THEN 'Written Off'
        ELSE 'Unknown'
    END AS loan_status_label,

    CASE
        WHEN loan_status_id = 600 THEN 'Closed'
        WHEN loan_status_id = 602 THEN 'Written Off'
        WHEN loan_status_id = 601 THEN 'Withdrawn'
        ELSE 'Open'
    END AS loan_lifecycle,

    -- Portfolio Flags
    CASE WHEN loan_status_id = 600 THEN 1 ELSE 0 END
        AS closed_loan_flag,

    CASE WHEN loan_status_id = 602 THEN 1 ELSE 0 END
        AS writtenoff_flag,

    CASE
        WHEN principal_outstanding_derived > 0
        THEN 1
        ELSE 0
    END AS outstanding_flag,

    CASE
        WHEN principal_outstanding_derived = 0
            AND COALESCE(total_writtenoff_derived,0) = 0
        THEN 1
        ELSE 0
    END AS fully_recovered_flag,

    CASE
        WHEN COALESCE(total_writtenoff_derived,0) > 0
            THEN 'Written Off'
        WHEN COALESCE(principal_outstanding_derived,0) > 0
            THEN 'Outstanding'
        ELSE 'Fully Recovered'
    END AS risk_flag,

    -- Loan Purpose
    loanpurpose_cv_id,

    CASE loanpurpose_cv_id
        WHEN 790 THEN 'Agriculture'
        WHEN 796 THEN 'Animal Husbandry'
        WHEN 797 THEN 'Trade/Commerce'
        WHEN 798 THEN 'Micro Enterprise'
        WHEN 794 THEN 'Housing'
        WHEN 791 THEN 'Business'
        WHEN 792 THEN 'Education'
        WHEN 793 THEN 'Health'
        WHEN 799 THEN 'Women Empowerment'
        WHEN 800 THEN 'Sanitation'
        WHEN 801 THEN 'Water'
        ELSE 'Others'
    END AS loan_purpose_label,

    -- Dates
    submittedon_date::DATE AS submitted_date,
    approvedon_date::DATE AS approved_date,
    disbursedon_date::DATE AS disbursement_date,
    closedon_date::DATE AS close_date,
    expected_maturedon_date::DATE AS maturity_date,
    last_repayment_date::DATE AS last_repayment_date,

    -- Financial Measures
    principal_amount,
    approved_principal,
    principal_amount_proposed,

    COALESCE(principal_disbursed_derived,0)
        AS principal_disbursed,

    COALESCE(principal_repaid_derived,0)
        AS principal_repaid,

    COALESCE(principal_outstanding_derived,0)
        AS principal_outstanding,

    COALESCE(principal_writtenoff_derived,0)
        AS principal_writtenoff,

    COALESCE(interest_charged_derived,0)
        AS interest_charged,

    COALESCE(interest_repaid_derived,0)
        AS interest_repaid,

    COALESCE(interest_outstanding_derived,0)
        AS interest_outstanding,

    COALESCE(interest_waived_derived,0)
        AS interest_waived,

    COALESCE(total_repayment_derived,0)
        AS total_repaid,

    COALESCE(total_expected_repayment_derived,0)
        AS total_expected_repayment,

    COALESCE(total_outstanding_derived,0)
        AS total_outstanding,

    COALESCE(total_writtenoff_derived,0)
        AS total_writtenoff,

    COALESCE(total_waived_derived,0)
        AS total_waived,

    fee_charges_charged_derived,
    total_charges_due_at_disbursement_derived,
    available_limit,

    -- Loan Configuration
    annual_nominal_interest_rate,
    number_of_repayments,
    calculated_installment_amount,

    -- Amount Segment
    CASE
        WHEN principal_amount <= 5000
            THEN 'Micro (<5K)'
        WHEN principal_amount <= 8000
            THEN 'Small (5K-8K)'
        WHEN principal_amount <= 10000
            THEN 'Medium (8K-10K)'
        ELSE 'Large (>10K)'
    END AS amount_segment,

    -- Loan Age
    CASE
        WHEN closedon_date IS NOT NULL
        THEN (closedon_date::DATE - disbursedon_date::DATE)
        ELSE (CURRENT_DATE - disbursedon_date::DATE)
    END AS loan_age_days,

    CASE
        WHEN (
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - disbursedon_date::DATE)
                ELSE (CURRENT_DATE - disbursedon_date::DATE)
            END
        ) <= 90 THEN '0-90 Days'

        WHEN (
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - disbursedon_date::DATE)
                ELSE (CURRENT_DATE - disbursedon_date::DATE)
            END
        ) <= 180 THEN '91-180 Days'

        WHEN (
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - disbursedon_date::DATE)
                ELSE (CURRENT_DATE - disbursedon_date::DATE)
            END
        ) <= 270 THEN '181-270 Days'

        ELSE '271-365 Days'
    END AS loan_cycle_bucket,

    -- KPIs
    ROUND(
        (
            COALESCE(principal_repaid_derived,0)
            * 100.0
            /
            NULLIF(principal_disbursed_derived,0)
        )::numeric,
        2
    ) AS repayment_rate_pct,

    ROUND(
        (
            COALESCE(principal_outstanding_derived,0)
            * 100.0
            /
            NULLIF(principal_disbursed_derived,0)
        )::numeric,
        2
    ) AS residual_exposure_pct,

    CASE
        WHEN (
            COALESCE(principal_repaid_derived,0)
            * 100.0
            /
            NULLIF(principal_disbursed_derived,0)
        ) >= 95 THEN 'Excellent'

        WHEN (
            COALESCE(principal_repaid_derived,0)
            * 100.0
            /
            NULLIF(principal_disbursed_derived,0)
        ) >= 80 THEN 'Good'

        WHEN (
            COALESCE(principal_repaid_derived,0)
            * 100.0
            /
            NULLIF(principal_disbursed_derived,0)
        ) >= 60 THEN 'Average'

        ELSE 'Poor'
    END AS repayment_band

FROM loan_stg;


CREATE OR REPLACE VIEW customer_view AS

SELECT

    -- Primary Key
    id AS customer_id,

    -- Foreign Key
    office_id AS branch_id,

    -- Staff
    COALESCE(staff_id::TEXT,'Unassigned')
        AS customer_staff_id,

    -- Customer Status
    status_enum AS customer_status_enum,

    CASE status_enum
        WHEN 100 THEN 'Submitted'
        WHEN 300 THEN 'Active'
        WHEN 600 THEN 'Closed'
        WHEN 700 THEN 'Rejected'
        ELSE 'Unknown'
    END AS customer_status_label,

    -- Customer Type
    COALESCE(client_type_cv_id::TEXT,'Unknown')
        AS client_type_cv_id,

    CASE
        WHEN client_type_cv_id = 877 THEN 'Individual'
        WHEN client_type_cv_id = 878 THEN 'Group'
        ELSE 'Unknown'
    END AS client_type_label,

    -- Closure Reason
    closure_reason_cv_id,

    -- Demographics
    gender_cv_id,

    CASE
        WHEN gender_cv_id = 50 THEN 'Female'
        ELSE 'Unknown'
    END AS gender_label,

    -- Flags
    CASE
        WHEN status_enum = 300 THEN 1
        ELSE 0
    END AS active_customer_flag,

    CASE
        WHEN status_enum = 600 THEN 1
        ELSE 0
    END AS closed_customer_flag,

    -- Dates
    submittedon_date::DATE AS customer_submitted_date,

    activation_date::DATE AS customer_activation_date,

    office_joining_date::DATE AS customer_joining_date,

    closedon_date::DATE AS customer_closed_date,

    -- Customer Tenure
    CASE
        WHEN closedon_date IS NOT NULL
        THEN (closedon_date::DATE - activation_date::DATE)
        ELSE (CURRENT_DATE - activation_date::DATE)
    END AS customer_tenure_days,

    -- Customer Segment
    CASE
        WHEN
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - activation_date::DATE)
                ELSE (CURRENT_DATE - activation_date::DATE)
            END <= 180
        THEN 'New Customer'

        WHEN
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - activation_date::DATE)
                ELSE (CURRENT_DATE - activation_date::DATE)
            END <= 365
        THEN 'Growing Customer'

        ELSE 'Established Customer'
    END AS customer_segment

    FROM customer_stg;

CREATE OR REPLACE VIEW group_view AS

SELECT

    -- Primary Key
    id AS group_id,

    -- Foreign Key
    office_id AS branch_id,

    -- Staff
    COALESCE(staff_id::TEXT,'Unassigned')
        AS group_staff_id,

    -- Group Status
    status_enum AS group_status_enum,

    CASE status_enum
        WHEN 0 THEN 'Pending'
        WHEN 100 THEN 'Submitted'
        WHEN 300 THEN 'Active'
        WHEN 600 THEN 'Closed'
        ELSE 'Unknown'
    END AS group_status_label,

    -- Group Hierarchy
    parent_id AS group_parent_id,

    level_id AS group_level_id,

    CASE level_id
        WHEN 1 THEN 'Center'
        WHEN 2 THEN 'Group'
        ELSE 'Other'
    END AS group_level_label,

    -- Closure Reason
    closure_reason_cv_id,

    -- Flags
    CASE
        WHEN status_enum = 300
        THEN 1
        ELSE 0
    END AS active_group_flag,

    CASE
        WHEN status_enum = 600
        THEN 1
        ELSE 0
    END AS closed_group_flag,

    CASE
        WHEN parent_id IS NOT NULL
        THEN 1
        ELSE 0
    END AS has_parent_group_flag,

    CASE
        WHEN parent_id IS NULL
        THEN 1
        ELSE 0
    END AS root_group_flag,

    -- Dates
    submittedon_date::DATE AS group_submitted_date,

    activation_date::DATE AS group_activation_date,

    closedon_date::DATE AS group_closed_date,

    -- Group Age
    CASE
        WHEN closedon_date IS NOT NULL
        THEN (closedon_date::DATE - activation_date::DATE)
        ELSE (CURRENT_DATE - activation_date::DATE)
    END AS group_age_days,

    -- Group Maturity
    CASE
        WHEN
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - activation_date::DATE)
                ELSE (CURRENT_DATE - activation_date::DATE)
            END <= 180
        THEN 'New Group'

        WHEN
            CASE
                WHEN closedon_date IS NOT NULL
                THEN (closedon_date::DATE - activation_date::DATE)
                ELSE (CURRENT_DATE - activation_date::DATE)
            END <= 365
        THEN 'Growing Group'

        ELSE 'Mature Group'
    END AS group_maturity

FROM group_stg;


CREATE OR REPLACE VIEW branch_view AS

SELECT

    -- Primary Key
    id AS branch_id,

    -- Hierarchy
    parent_id AS branch_parent_id,

    -- Branch Details
    office_code AS branch_office_code,

    status_enum AS branch_status_enum,

    CASE status_enum
        WHEN 300 THEN 'Active'
        WHEN 0 THEN 'Inactive'
        ELSE 'Unknown'
    END AS branch_status_label,

    -- Branch Type
    is_fieldoffice,

    CASE
        WHEN is_fieldoffice = TRUE
        THEN 'Field Office'
        ELSE 'Head/Regional Office'
    END AS branch_type,

    CASE
        WHEN is_fieldoffice = TRUE
        THEN 1
        ELSE 0
    END AS field_office_flag,

    -- Status Flags
    CASE
        WHEN status_enum = 300
        THEN 1
        ELSE 0
    END AS active_branch_flag,

    CASE
        WHEN status_enum = 0
        THEN 1
        ELSE 0
    END AS inactive_branch_flag,

    -- Dates
    opening_date::DATE AS branch_opening_date,

    activation_date::DATE AS branch_activation_date,

    -- Branch Age
    CASE
        WHEN opening_date IS NOT NULL
        THEN (CURRENT_DATE - opening_date::DATE)
        ELSE NULL
    END AS branch_age_days,

    -- Branch Age Segment
    CASE
        WHEN (CURRENT_DATE - opening_date::DATE) <= 365
        THEN 'New Branch'

        WHEN (CURRENT_DATE - opening_date::DATE) <= 1095
        THEN 'Growing Branch'

        ELSE 'Mature Branch'
    END AS branch_maturity

FROM branch_stg;

CREATE OR REPLACE VIEW loan_type_view AS

SELECT

    -- Primary Key
    id AS product_id,

    -- Product Code
    external_id AS product_code,

    -- Principal Configuration
    principal_amount AS product_default_principal,

    min_principal_amount AS product_min_principal,

    max_principal_amount AS product_max_principal,

    -- Interest Configuration
    nominal_interest_rate_per_period,

    annual_nominal_interest_rate AS product_annual_rate,

    -- Repayment Configuration
    number_of_repayments AS product_repayment_count,

    repay_every,

    repayment_period_frequency_enum,

    CASE repayment_period_frequency_enum
        WHEN 0 THEN 'Daily'
        WHEN 1 THEN 'Weekly'
        WHEN 2 THEN 'Bi-Weekly'
        WHEN 3 THEN 'Monthly'
        WHEN 4 THEN 'Yearly'
        ELSE 'Other'
    END AS repayment_frequency_label,

    -- Risk Configuration
    overdue_days_for_npa AS product_npa_threshold_days,

    CASE
        WHEN overdue_days_for_npa <= 30
            THEN 'Low Risk'
        WHEN overdue_days_for_npa <= 60
            THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS product_risk_band,

    -- Accounting Type
    accounting_type,

    CASE accounting_type
        WHEN 1 THEN 'Cash Based'
        WHEN 3 THEN 'Accrual Based'
        ELSE 'Other'
    END AS accounting_type_label,

    -- Fund Source
    fund_id,

    -- Product Dates
    start_date::DATE AS product_start_date,

    close_date::DATE AS product_close_date,

    -- Active Product Flag
    CASE
        WHEN close_date IS NULL
            OR close_date::DATE > CURRENT_DATE
        THEN 1
        ELSE 0
    END AS active_product_flag,

    CASE
        WHEN close_date IS NULL
            OR close_date::DATE > CURRENT_DATE
        THEN 'Active Product'
        ELSE 'Closed Product'
    END AS product_status_label,

    -- Product Age
    CASE
        WHEN start_date IS NOT NULL
        THEN (CURRENT_DATE - start_date::DATE)
        ELSE NULL
    END AS product_age_days,

    -- Product Maturity
    CASE
        WHEN (CURRENT_DATE - start_date::DATE) <= 365
            THEN 'New Product'

        WHEN (CURRENT_DATE - start_date::DATE) <= 1095
            THEN 'Growing Product'

        ELSE 'Mature Product'
    END AS product_maturity,

    -- Product Size Tier
    CASE
        WHEN principal_amount <= 5000
            THEN 'Micro (<5K)'

        WHEN principal_amount <= 8000
            THEN 'Small (5K-8K)'

        WHEN principal_amount <= 10000
            THEN 'Medium (8K-10K)'

        ELSE 'Large (>10K)'
    END AS product_size_tier,

    -- Interest Rate Tier
    CASE
        WHEN annual_nominal_interest_rate >= 20
            THEN 'High Rate'

        WHEN annual_nominal_interest_rate >= 12
            THEN 'Medium Rate'

        WHEN annual_nominal_interest_rate > 0
            THEN 'Low Rate'

        ELSE 'Unknown'
    END AS interest_rate_tier

FROM loan_type_stg;



