import logging
import pandas as pd
from sqlalchemy import text

from database import get_engine
from config import SCHEMA, SOURCE_TABLES

log = logging.getLogger(__name__)


def extract_table(table_key: str) -> pd.DataFrame:
    if table_key not in SOURCE_TABLES:
        raise KeyError(f"Unknown key: '{table_key}'. Valid: {list(SOURCE_TABLES)}")

    tbl = SOURCE_TABLES[table_key]
    engine = get_engine()

    try:
        log.info(f"[EXTRACT] {SCHEMA}.{tbl} ...")

        with engine.connect() as conn:
            print("CONN TYPE:", type(conn))

            result = conn.execute(text(f'SELECT * FROM {SCHEMA}."{tbl}"'))

            rows = result.fetchall()
            cols = result.keys()

            df = pd.DataFrame(rows, columns=cols)

        log.info(f"  → {df.shape[0]:,} rows | {df.shape[1]} cols")
        return df

    finally:
        engine.dispose()


def extract_all() -> dict[str, pd.DataFrame]:
    return {key: extract_table(key) for key in SOURCE_TABLES}
