#!/usr/bin/env python3
"""E2E local para el flujo de donaciones.

Requisitos: instalar dependencies listadas en `scripts/requirements_e2e.txt`.

Pasos:
 - registrar un usuario de prueba
 - login y obtención de JWT
 - crear sesión en modo local (`X-Force-Local: true`)
 - enviar webhook firmado a `/webhook/stripe`
 - verificar filas en Postgres dentro del contenedor docker

Uso:
  python scripts/e2e_donaciones.py

"""
import os
import sys
import time
import json
import hmac
import hashlib
import subprocess

import requests

ROOT = os.path.dirname(os.path.dirname(__file__))
ENV_PATH = os.path.join(ROOT, '.env')
BACKEND = os.environ.get('BACKEND_URL', 'http://localhost:8081')


def read_env(path):
    env = {}
    try:
        with open(path, 'r', encoding='utf-8') as f:
            for ln in f:
                ln = ln.strip()
                if not ln or ln.startswith('#'):
                    continue
                if '=' in ln:
                    k, v = ln.split('=', 1)
                    env[k.strip()] = v.strip().strip('"').strip("'")
    except FileNotFoundError:
        pass
    return env


def run_cmd(cmd):
    print('> ' + cmd)
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p


def docker_psql(query):
    q = query.replace('"', '\"')
    cmd = f'docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "{q}"'
    return run_cmd(cmd)


def send_signed_webhook(secret, session_id, donacion_id):
    event = {
        "id": "evt_e2e_python",
        "object": "event",
        "api_version": "2023-08-16",
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "id": session_id,
                "object": "checkout.session",
                "payment_status": "paid",
                "payment_intent": None,
                "amount_total": 500,
                "currency": "usd",
                "metadata": { "donacion_id": str(donacion_id) }
            }
        }
    }
    payload = json.dumps(event, separators=(',', ':'), ensure_ascii=False)
    timestamp = str(int(time.time()))
    signed = timestamp + '.' + payload
    sig = hmac.new(secret.encode('utf-8'), signed.encode('utf-8'), hashlib.sha256).hexdigest()
    header = f't={timestamp},v1={sig}'

    url = BACKEND.rstrip('/') + '/webhook/stripe'
    headers = {'Content-Type': 'application/json', 'Stripe-Signature': header}
    print('Sending webhook to', url)
    resp = requests.post(url, data=payload.encode('utf-8'), headers=headers, timeout=20)
    print('Webhook status:', resp.status_code)
    print('Response:', resp.text)
    return resp


def main():
    env = read_env(ENV_PATH)
    webhook_secret = env.get('STRIPE_WEBHOOK_SECRET', os.environ.get('STRIPE_WEBHOOK_SECRET', ''))
    if not webhook_secret:
        print('Warning: STRIPE_WEBHOOK_SECRET not found. Webhook will be unsigned and may be rejected.')

    # Register user
    reg = {'nombre': 'E2E', 'apellido': 'Test', 'email': 'e2e+local@recetas.local', 'password': 'E2E_pass123!'}
    print('Registering test user...')
    r = requests.post(BACKEND + '/auth/register', json=reg)
    print('register', r.status_code)
    print(r.text)

    # Login
    login = {'email': reg['email'], 'password': reg['password']}
    print('Logging in...')
    r = requests.post(BACKEND + '/auth/login', json=login)
    if r.status_code != 200:
        print('Login failed:', r.status_code, r.text)
        sys.exit(1)
    token = r.json().get('token')
    if not token:
        print('Token not returned by login.')
        sys.exit(1)
    print('Token obtained')

    headers = {'Authorization': f'Bearer {token}', 'X-Force-Local': 'true'}

    # Create session
    create_body = {'amount': 500, 'currency': 'usd', 'correo': reg['email'], 'idReceta': 21}
    print('Creating local donation session...')
    r = requests.post(BACKEND + '/donaciones/create-session', json=create_body, headers=headers)
    print('create-session', r.status_code)
    print(r.text)
    if r.status_code not in (200, 201):
        print('create-session failed')
        sys.exit(1)
    resp = r.json()
    sesion = resp.get('sesion_pago') or resp.get('sesion') or {}
    session_id = sesion.get('sessionId') or sesion.get('session_id') or resp.get('sessionId')
    donacion = resp.get('donacion') or resp.get('donation')
    donacion_id = None
    if isinstance(donacion, dict):
        donacion_id = donacion.get('idDonacion') or donacion.get('id_donacion') or donacion.get('id')
    print('session_id=', session_id, 'donacion_id=', donacion_id)

    # Send webhook
    if webhook_secret:
        print('Sending signed webhook...')
        send_signed_webhook(webhook_secret, session_id, donacion_id)
    else:
        print('Sending unsigned webhook (no STRIPE_WEBHOOK_SECRET)')
        url = BACKEND.rstrip('/') + '/webhook/stripe'
        event = { 'type': 'checkout.session.completed', 'data': {'object': {'id': session_id}} }
        r = requests.post(url, json=event)
        print('status', r.status_code, r.text)

    time.sleep(1)

    # Verify DB rows
    q1 = f"SELECT id_donacion, status, stripe_session_id, stripe_payment_intent FROM donacion WHERE id_donacion = {donacion_id};"
    r1 = docker_psql(q1)
    print(r1.stdout)
    q2 = f"SELECT session_id, status, id_donacion, metadata::text FROM sesion_pago WHERE session_id = '{session_id}';"
    r2 = docker_psql(q2)
    print(r2.stdout)


if __name__ == '__main__':
    main()
