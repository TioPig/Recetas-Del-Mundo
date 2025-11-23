#!/usr/bin/env python3
import json, urllib.request, urllib.parse, sys

# Usar servidor de producción por IP (HTTP sin SSL)
BASE_URL = 'http://168.181.187.137/api'

login_payload = json.dumps({"email":"admin@recetas.com","password":"cast1301"}).encode('utf-8')
login_req = urllib.request.Request(f'{BASE_URL}/auth/login', data=login_payload, headers={'Content-Type':'application/json'})
with urllib.request.urlopen(login_req, timeout=10) as r:
    body = r.read().decode('utf-8')
    data = json.loads(body)
    token = data.get('token') or data.get('jwt') or data.get('data', {}).get('token')
    if not token:
        print('Could not obtain token from login response:', data)
        sys.exit(1)

session_id = sys.argv[1] if len(sys.argv)>1 else 'cs_test_a1E3YGkA3PejTaqhYlAeWSptY5JU9ALcZ71V64TAyQF9FwI4wLzdH8gybr'
verify_payload = json.dumps({"sessionId": session_id}).encode('utf-8')
verify_req = urllib.request.Request(f'{BASE_URL}/donaciones/verify-session', data=verify_payload, headers={'Content-Type':'application/json','Authorization': 'Bearer '+token})
try:
    with urllib.request.urlopen(verify_req, timeout=20) as r2:
        print('STATUS', r2.getcode())
        print(r2.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print('HTTP', e.code)
    try:
        print(e.read().decode('utf-8'))
    except Exception:
        pass
except Exception as e:
    print('ERROR', e)
