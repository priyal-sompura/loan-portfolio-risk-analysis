"""
=============================================================
    TRANSFORM — Clean each table
    File     : etl/transform/transform.py
=============================================================
"""

import logging
import pandas as pd

log = logging.getLogger(__name__)


def _to_datetime(df, cols):
    for col in cols:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")
    return df


def _drop_cols(df, cols, label):
    before = df.shape[1]
    df = df.drop(columns=cols, errors="ignore")
    log.info(
        f"  [{label}] dropped {before - df.shape[1]} cols → {df.shape[1]} remaining"
    )
    return df


def _fill_mode(df, cols):
    for col in cols:
        if col in df.columns and df[col].isnull().any():
            df[col] = df[col].fillna(df[col].mode()[0])
    return df


def _fill_median(df, cols):
    for col in cols:
        if col in df.columns and df[col].isnull().any():
            df[col] = df[col].fillna(df[col].median())
    return df


def _fill_zero(df, cols):
    for col in cols:
        if col in df.columns:
            df[col] = df[col].fillna(0)
    return df


def transform_branch(df):
    log.info("[TRANSFORM] branch")
    df = _to_datetime(df, ["opening_date", "activation_date", "rejectedon_date"])
    for col in ["activatedby_userid", "rejectedby_userid"]:
        if col in df.columns:
            df[col] = df[col].astype("Int64")
    df = _drop_cols(
        df,
        [
            "rejectedby_userid",
            "rejectedon_date",
            "activatedby_userid",
            "lastmodified_date",
        ],
        "branch",
    )
    log.info(f"  dupes={df.duplicated().sum()} nulls={df.isnull().sum().sum()}")
    return df


def transform_customer(df):
    log.info("[TRANSFORM] customer")
    df = _to_datetime(
        df,
        [
            "activation_date",
            "office_joining_date",
            "closedon_date",
            "submittedon_date",
            "rejectedon_date",
            "withdrawn_on_date",
            "reactivated_on_date",
            "reopened_on_date",
            "verified_date",
        ],
    )
    df = _drop_cols(
        df,
        [
            "sub_status",
            "reopened_on_date",
            "legal_form_enum",
            "verified_date",
            "reopened_by_userid",
            "reject_type",
            "withdraw_reason_cv_id",
            "withdraw_on_userid",
            "withdrawn_on_date",
            "reject_reason_cv_id",
            "rejectedon_date",
            "rejectedon_userid",
            "marital_status_cv_id",
            "activatedon_userid",
            "transfer_to_office_id",
            "updated_on",
            "updated_by",
            "reactivated_on_date",
            "reactivated_on_userid",
            "client_classification_cv_id",
        ],
        "customer",
    )
    df = _fill_mode(df, ["staff_id"])
    log.info(f"  dupes={df.duplicated().sum()} nulls={df.isnull().sum().sum()}")
    return df


def transform_group(df):
    log.info("[TRANSFORM] group")
    df = _to_datetime(df, ["activation_date", "closedon_date", "submittedon_date"])
    df = _drop_cols(df, ["activatedon_userid"], "group")
    df = _fill_mode(df, ["staff_id"])
    log.info(f"  dupes={df.duplicated().sum()} nulls={df.isnull().sum().sum()}")
    return df


def transform_loan_type(df):
    log.info("[TRANSFORM] loan_type")
    df = _to_datetime(df, ["start_date", "close_date"])
    df = _drop_cols(
        df,
        [
            "adjusted_instalment_in_multiples_of",
            "max_disbursals",
            "grace_interest_free_periods",
            "recurring_moratorium_principal_periods",
            "no_of_adv_emi_collection",
            "max_periods_between_disbursal_and_first_repayment",
            "payment_type_for_repayment_at_disbursement",
            "category_id",
            "min_periods_between_disbursal_and_first_repayment",
            "partial_period_type_enum",
            "grace_on_arrears_ageing",
            "max_outstanding_loan_balance",
            "max_days_between_disbursal_and_first_repayment",
            "max_instalment_amount",
            "interest_rates_list_per_period",
            "min_days_between_approval_and_disbursal",
            "percentage_of_disbursement_to_be_transferred",
            "broken_period_method_enum",
            "max_loan_term",
            "min_loan_term",
            "broken_period_days_in_month_enum",
            "recurrence",
            "broken_period_days_in_year_enum",
            "grace_on_interest_periods",
            "min_days_between_disbursal_and_first_repayment",
            "pmt_calculated_in_period_enum",
            "grace_on_principal_periods",
        ],
        "loan_type",
    )
    df = _fill_mode(df, ["borrower_cycle_type", "overdue_days_for_npa", "fund_id"])
    df = _fill_median(df, ["min_number_of_repayments", "max_number_of_repayments"])
    df = _fill_zero(
        df, ["arrearstolerance_amount", "instalment_amount_in_multiples_of"]
    )
    log.info(f"  dupes={df.duplicated().sum()} nulls={df.isnull().sum().sum()}")
    return df


def transform_loan(df):
    log.info("[TRANSFORM] loan")
    df = _to_datetime(
        df,
        [
            "submittedon_date",
            "approvedon_date",
            "expected_disbursedon_date",
            "expected_firstrepaymenton_date",
            "interest_calculated_from_date",
            "disbursedon_date",
            "expected_maturedon_date",
            "maturedon_date",
            "closedon_date",
            "last_repayment_date",
        ],
    )
    df = _drop_cols(
        df,
        [
            "arrearstolerance_amount",
            "currency_multiplesof",
            "grace_on_principal_periods",
            "grace_interest_free_periods",
            "grace_on_interest_periods",
            "recurring_moratorium_principal_periods",
            "sync_disbursement_with_meeting",
            "withdrawnon_userid",
            "withdrawnon_date",
            "disbursedon_userid",
            "rejectedon_userid",
            "total_overpaid_derived",
            "rescheduledon_userid",
            "rescheduledon_date",
            "partial_period_type_enum",
            "loan_recalcualated_on",
            "interest_recalcualated_on",
            "accrued_till",
            "total_recovered_derived",
            "grace_on_arrears_ageing",
            "max_outstanding_loan_balance",
            "fixed_emi_amount",
            "calculated_maturedon_date",
            "pmt_calculated_in_period_enum",
            "broken_period_method_enum",
            "flat_interest_rate",
            "broken_period_interest",
            "discount_on_disbursal_amount",
            "amount_for_upfront_collection",
            "max_instalment_amount",
            "guarantee_amount_derived",
            "create_standing_instruction_at_disbursement",
            "writeoff_reason_cv_id",
            "loan_sub_status_id",
            "first_emi_amount",
            "repayment_history_version",
            "expected_disbursal_payment_type_id",
            "expected_repayment_payment_type_id",
            "no_of_adv_emi_collection",
            "payment_type_for_repayment_at_disbursement",
            "total_excess_amount_derived",
            "total_income_posted",
            "broken_period_days_in_year_enum",
            "broken_period_days_in_month_enum",
            "total_upfront_interest_amount_derived",
            "rejectedon_date",
            "writtenoffon_date",
            "fund_id",
        ],
        "loan",
    )
    df = _fill_zero(df, ["loan_counter", "loan_product_counter"])
    df = _fill_mode(df, ["loanpurpose_cv_id", "loan_purpose_id"])
    log.info(f"  dupes={df.duplicated().sum()} nulls={df.isnull().sum().sum()}")
    return df


_TRANSFORM_MAP = {
    "branch": transform_branch,
    "customer": transform_customer,
    "group": transform_group,
    "loan_type": transform_loan_type,
    "loan": transform_loan,
}


def transform_table(key: str, df: pd.DataFrame) -> pd.DataFrame:
    if key not in _TRANSFORM_MAP:
        raise ValueError(f"No transform for key: '{key}'")
    return _TRANSFORM_MAP[key](df.copy())
