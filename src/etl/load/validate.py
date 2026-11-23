"""
=============================================================
    VALIDATE — Quality checks on cleaned DataFrames
    File     : etl/load/validate.py
=============================================================
"""

import logging
import pandas as pd

log = logging.getLogger(__name__)


def validate_table(key: str, df: pd.DataFrame) -> None:
    log.info(f"[VALIDATE] {key}")
    if df.empty:
        raise ValueError(f"[{key}] DataFrame is empty after transform!")
    log.info(f"  rows={len(df):,}  ✓")
    if "id" in df.columns:
        dupes = int(df["id"].duplicated().sum())
        if dupes:
            raise ValueError(f"[{key}] {dupes} duplicate PK(s) in 'id'!")
        log.info(f"  PK uniqueness OK  ✓")
    nulls = int(df.isnull().sum().sum())
    if nulls:
        top = df.isnull().sum().nlargest(5).to_dict()
        log.warning(f"  {nulls} nulls remain (top: {top})")
    else:
        log.info(f"  0 nulls  ✓")


def validate_all(dfs: dict[str, pd.DataFrame]) -> None:
    for key, df in dfs.items():
        validate_table(key, df)
    log.info("[VALIDATE] All tables passed.")
