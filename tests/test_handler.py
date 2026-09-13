import json
import os
import sys
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parents[1] / 'src'))
os.environ['JWT_SECRET'] = 'test-secret'

from handler import lambda_handler


def test_invalid_cpf():
    result = lambda_handler({'body': json.dumps({'cpf': '11111111111'})}, None)
    assert result['statusCode'] == 400


@patch('handler.find_customer_by_cpf')
def test_valid_customer_returns_token(mock_find):
    mock_find.return_value = {'id': '123', 'cpf': '52998224725', 'active': True}
    result = lambda_handler({'body': json.dumps({'cpf': '52998224725'})}, None)
    assert result['statusCode'] == 200
    assert 'access_token' in json.loads(result['body'])
