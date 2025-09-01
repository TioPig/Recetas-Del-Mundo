"""
Script to hash existing plaintext passwords in Postgres using bcrypt.
Usage:
  pip install psycopg2-binary bcrypt
  python hash_existing_passwords.py --pg 'postgresql://recetas:recetas@localhost:5432/recetas'

This script will:
 - Read users with non-empty password
 - Hash the password using bcrypt and update the `usuario.password` field
 - Print a warning; run on a maintenance window or backup DB first.
"""
import argparse
import bcrypt
import psycopg2

parser = argparse.ArgumentParser()
parser.add_argument('--pg', default='postgresql://recetas:recetas@localhost:5432/recetas')
args = parser.parse_args()

dsn = args.pg
print('Connecting to', dsn)
conn = psycopg2.connect(dsn)
cur = conn.cursor()
cur.execute("SELECT id_usr, password FROM usuario WHERE password IS NOT NULL AND password <> ''")
rows = cur.fetchall()
print('Found', len(rows), 'users')
for uid, pwd in rows:
    # if pwd already looks like bcrypt ($2b$...), skip
    if pwd.startswith('$2'):
        print('Skipping', uid, 'already hashed')
        continue
    hashed = bcrypt.hashpw(pwd.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    cur.execute("UPDATE usuario SET password = %s WHERE id_usr = %s", (hashed, uid))
    print('Updated', uid)
conn.commit()
cur.close()
conn.close()
print('Done')
