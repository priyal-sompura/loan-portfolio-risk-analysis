import logging

from extract.extract import extract_all
from transform.transform import transform_table
from load.validate import validate_all
from load.load import (
    load_all,
    apply_constraints,
    verify_constraints,
    post_load_validation,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)

log = logging.getLogger(__name__)

from sqlalchemy import text
from database import get_engine
from config import SCHEMA


def constraints_exist():

    engine = get_engine()

    with engine.connect() as conn:
        count = conn.execute(
            text("""
                SELECT COUNT(*)
                FROM information_schema.table_constraints
                WHERE table_schema = :schema
                AND constraint_type IN ('PRIMARY KEY','FOREIGN KEY')
            """),
            {"schema": SCHEMA},
        ).scalar()

    engine.dispose()

    return count > 0


def run():

    log.info("===== ETL STARTED =====")

    # 1. Extract
    raw_dfs = extract_all()

    # 2. Transform
    cleaned_dfs = {}

    for key, df in raw_dfs.items():
        cleaned_dfs[key] = transform_table(key, df)

    # 3. Validate
    validate_all(cleaned_dfs)

    # 4. Load
    load_all(cleaned_dfs)

    # 5. Apply Constraints
    if not constraints_exist():
        log.info("[CONSTRAINTS] Creating constraints...")
        apply_constraints()
    else:
        log.info("[CONSTRAINTS] Already exist. Skipping.")

    # 6. Verify Constraints
    verify_constraints()

    # 7. Post Load Validation
    post_load_validation()

    log.info("===== ETL COMPLETED =====")


if __name__ == "__main__":
    run()
