import psycopg2

conn = psycopg2.connect(
    host="172.18.64.1",
    port=5432,
    database="loan_portfolio_db",
    user="postgres",
    password="root",
)

print("Connected successfully!")

cur = conn.cursor()
cur.execute("SELECT current_database();")
print(cur.fetchone())

conn.close()
