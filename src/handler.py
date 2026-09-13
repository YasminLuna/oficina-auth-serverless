import json
import os
from datetime import datetime, timedelta, timezone

import jwt

from cpf import is_valid_cpf, only_digits
from db import find_customer_by_cpf


def response(status: int, body: dict):
    return {
        'statusCode': status,
        'headers': {'content-type': 'application/json'},
        'body': json.dumps(body, ensure_ascii=False),
    }


def lambda_handler(event, context):
    try:
        payload = json.loads(event.get('body') or '{}')
        cpf = only_digits(str(payload.get('cpf', '')))

        if not is_valid_cpf(cpf):
            return response(400, {'detail': 'CPF inválido'})

        customer = find_customer_by_cpf(cpf)
        if customer is None:
            return response(404, {'detail': 'Cliente não encontrado'})
        if not customer['active']:
            return response(403, {'detail': 'Cliente inativo'})

        now = datetime.now(timezone.utc)
        ttl = int(os.getenv('ACCESS_TOKEN_EXPIRE_MINUTES', '60'))
        claims = {
            'sub': customer['id'],
            'cpf': cpf,
            'iat': int(now.timestamp()),
            'exp': int((now + timedelta(minutes=ttl)).timestamp()),
            'iss': 'oficina-auth',
        }
        token = jwt.encode(claims, os.environ['JWT_SECRET'], algorithm='HS256')
        return response(200, {'access_token': token, 'token_type': 'bearer', 'expires_in': ttl * 60})
    except Exception as exc:
        print(json.dumps({'level': 'ERROR', 'message': 'authentication_failed', 'error': str(exc)}))
        return response(500, {'detail': 'Falha interna de autenticação'})
