import os
import psycopg


def _database_dsn() -> str:
    dsn = os.environ['DATABASE_URL']
    # SQLAlchemy uses postgresql+psycopg://, while psycopg expects postgresql://.
    return dsn.replace('postgresql+psycopg://', 'postgresql://', 1)


def find_customer_by_cpf(cpf: str):
    with psycopg.connect(_database_dsn(), connect_timeout=5) as conn:
        with conn.cursor() as cur:
            cur.execute(
                'SELECT id, document, active FROM customers WHERE document = %s LIMIT 1',
                (cpf,),
            )
            row = cur.fetchone()
            if not row:
                return None
            return {'id': str(row[0]), 'cpf': row[1], 'active': bool(row[2])}
