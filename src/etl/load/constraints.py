"""
=============================================================
    CONSTRAINTS — PK / FK for staging tables
    File       : etl/load/constraints.py
=============================================================
"""

from config import SCHEMA

CONSTRAINT_ORDER = [
    "branch_stg",
    "customer_stg",
    "group_stg",
    "loan_type_stg",
    "loan_stg",
]

CONSTRAINTS = {
    "branch_stg": [
        f"ALTER TABLE {SCHEMA}.branch_stg ADD CONSTRAINT branch_stg_pk PRIMARY KEY (id);",
    ],
    "customer_stg": [
        f"ALTER TABLE {SCHEMA}.customer_stg ADD CONSTRAINT customer_stg_pk PRIMARY KEY (id);",
        f"ALTER TABLE {SCHEMA}.customer_stg ADD CONSTRAINT customer_stg_fk_office "
        f"FOREIGN KEY (office_id) REFERENCES {SCHEMA}.branch_stg(id);",
    ],
    "group_stg": [
        f"ALTER TABLE {SCHEMA}.group_stg ADD CONSTRAINT group_stg_pk PRIMARY KEY (id);",
        f"ALTER TABLE {SCHEMA}.group_stg ADD CONSTRAINT group_stg_fk_office "
        f"FOREIGN KEY (office_id) REFERENCES {SCHEMA}.branch_stg(id);",
    ],
    "loan_type_stg": [
        f"ALTER TABLE {SCHEMA}.loan_type_stg ADD CONSTRAINT loan_type_stg_pk PRIMARY KEY (id);",
    ],
    "loan_stg": [
        f"ALTER TABLE {SCHEMA}.loan_stg ADD CONSTRAINT loan_stg_pk PRIMARY KEY (id);",
        f"ALTER TABLE {SCHEMA}.loan_stg ADD CONSTRAINT loan_stg_fk_client "
        f"FOREIGN KEY (client_id) REFERENCES {SCHEMA}.customer_stg(id);",
        f"ALTER TABLE {SCHEMA}.loan_stg ADD CONSTRAINT loan_stg_fk_group "
        f"FOREIGN KEY (group_id) REFERENCES {SCHEMA}.group_stg(id);",
        f"ALTER TABLE {SCHEMA}.loan_stg ADD CONSTRAINT loan_stg_fk_product "
        f"FOREIGN KEY (product_id) REFERENCES {SCHEMA}.loan_type_stg(id);",
        # f"ALTER TABLE {SCHEMA}.loan_stg ADD CONSTRAINT loan_stg_fk_office "
        # f"FOREIGN KEY (office_id) REFERENCES {SCHEMA}.branch_stg(id);",
    ],
}
