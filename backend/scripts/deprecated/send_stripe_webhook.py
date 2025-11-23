#!/usr/bin/env python3
import sys, json, time, hmac, hashlib, urllib.request

# args: <webhook_secret> <session_id> [donacion_id]
if len(sys.argv) < 3:
    print('Usage: send_stripe_webhook.py <webhook_secret> <session_id> [donacion_id]')
    sys.exit(2)
secret = sys.argv[1]
session_id = sys.argv[2]
donacion_id = sys.argv[3] if len(sys.argv) > 3 else None

# build a minimal checkout.session.completed event
event = {
    "id": "evt_test_123",
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
            "metadata": { "donacion_id": (donacion_id if donacion_id is not None else "18") }
        }
    }
}

payload = json.dumps(event, separators=(',', ':'), ensure_ascii=False)
timestamp = str(int(time.time()))
_signed = timestamp + '.' + payload
sig = hmac.new(secret.encode('utf-8'), _signed.encode('utf-8'), hashlib.sha256).hexdigest()
header = f"t={timestamp},v1={sig}"

url = 'http://localhost:8081/webhook/stripe'
req = urllib.request.Request(url, data=payload.encode('utf-8'), method='POST')
req.add_header('Content-Type', 'application/json')
req.add_header('Stripe-Signature', header)

print('Sending webhook to', url)
print('Stripe-Signature:', header)
try:
    with urllib.request.urlopen(req, timeout=20) as resp:
        body = resp.read().decode('utf-8')
        print('STATUS', resp.getcode())
        print('RESPONSE', body)
except urllib.error.HTTPError as e:
    print('HTTPERROR', e.code)
    try:
        print(e.read().decode('utf-8'))
    except Exception:
        pass
except Exception as e:
    print('ERROR', e)
