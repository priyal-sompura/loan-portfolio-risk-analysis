"""
=============================================================
    LOAD — Write staging tables + apply PK/FK constraints
    File : etl/load/load.py
=============================================================
"""

import logging
import pandas as pd
from sqlalchemy import text
from database import get_engine
from config import SCHEMA, STAGING_MAP, TABLE_ORDER
from load.constraints import CONSTRAINTS, CONSTRAINT_ORDER

log = logging.getLogger(__name__)


def truncate_tables():
    engine = get_engine()

    with engine.begin() as conn:
        conn.execute(text(f"""
                TRUNCATE TABLE
                    {SCHEMA}.group_stg,
                    {SCHEMA}.customer_stg,
                    {SCHEMA}.branch_stg,
                    {SCHEMA}.loan_stg,
                    {SCHEMA}.loan_type_stg
                RESTART IDENTITY CASCADE;
            """))

    engine.dispose()


def load_table(key: str, df: pd.DataFrame) -> None:
    stg = STAGING_MAP[key]
    engine = get_engine()

    try:
        log.info(f"[LOAD] {SCHEMA}.{stg} ({len(df):,} rows) ...")

        with engine.begin() as conn:
            df.to_sql(
                name=stg,
                con=conn,
                schema=SCHEMA,
                if_exists="append",
                index=False,
                method="multi",
                chunksize=500,
            )

        log.info(f"  ✓ {stg} loaded.")

    finally:
        engine.dispose()


def load_all(dfs: dict[str, pd.DataFrame]) -> None:

    truncate_tables()

    for key in TABLE_ORDER:
        if key in dfs:
            load_table(key, dfs[key])

    log.info("[LOAD] All staging tables loaded.")


def _constraint_name(stmt: str) -> str | None:
    upper = stmt.upper()
    idx = upper.find("ADD CONSTRAINT")
    if idx == -1:
        return None
    return stmt[idx + 14 :].strip().split()[0].rstrip(";")


def apply_constraints() -> None:
    engine = get_engine()
    log.info("[CONSTRAINTS] Applying PK / FK ...")
    with engine.begin() as conn:
        for tbl in CONSTRAINT_ORDER:
            for stmt in CONSTRAINTS.get(tbl, []):
                name = _constraint_name(stmt)
                if name:
                    conn.execute(
                        text(
                            f"ALTER TABLE {SCHEMA}.{tbl} DROP CONSTRAINT IF EXISTS {name};"
                        )
                    )
                conn.execute(text(stmt))
                log.info(f"  Applied: {name}")
    engine.dispose()
    log.info("[CONSTRAINTS] Done.")


def verify_constraints() -> None:
    engine = get_engine()
    log.info("[VERIFY] Checking constraints ...")
    q = text("""
        SELECT tc.constraint_name, tc.constraint_type, tc.table_name,
        kcu.column_name,
        ccu.table_name AS ref_table, ccu.column_name AS ref_col
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
        LEFT JOIN information_schema.constraint_column_usage ccu
        ON tc.constraint_name = ccu.constraint_name AND tc.table_schema = ccu.table_schema
        WHERE tc.table_schema = :schema
        AND tc.table_name   = ANY(:tables)
        AND tc.constraint_type IN ('PRIMARY KEY','FOREIGN KEY')
        ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;
    """)
    with engine.connect() as conn:
        rows = conn.execute(
            q, {"schema": SCHEMA, "tables": list(STAGING_MAP.values())}
        ).fetchall()
    for r in rows:
        log.info(
            f"  {r.constraint_name:<35} {r.constraint_type:<12} "
            f"{r.table_name}.{r.column_name} → {r.ref_table or ''}"
        )
    log.info(f"[VERIFY] {len(rows)} constraint(s) confirmed.")
    engine.dispose()


def post_load_validation() -> None:
    engine = get_engine()
    log.info("[POST-LOAD] Row / col counts ...")
    with engine.connect() as conn:
        for stg in STAGING_MAP.values():
            rows = conn.execute(text(f"SELECT COUNT(*) FROM {SCHEMA}.{stg}")).scalar()
            cols = conn.execute(
                text(
                    "SELECT COUNT(*) FROM information_schema.columns "
                    f"WHERE table_schema='{SCHEMA}' AND table_name='{stg}'"
                )
            ).scalar()
            log.info(f"  {stg:<22} {rows:>8,} rows  {cols:>4} cols")
    engine.dispose()
