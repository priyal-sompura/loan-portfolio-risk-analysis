"""
=============================================================
    DATABASE — SQLAlchemy engine factory
    File    : etl/database.py
=============================================================
"""

import logging
from sqlalchemy import create_engine, text
from config import DB_CONFIG

log = logging.getLogger(__name__)


def get_engine():
    """Build and verify a PostgreSQL SQLAlchemy engine."""
    url = (
        f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}"
    )
    engine = create_engine(url, pool_pre_ping=True)
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    log.info("✓ PostgreSQL connected.")
    return engine
