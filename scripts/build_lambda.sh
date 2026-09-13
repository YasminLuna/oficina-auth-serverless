#!/usr/bin/env bash
set -euo pipefail
rm -rf build
mkdir -p build
python -m pip install -r requirements.txt -t build
cp src/*.py build/
