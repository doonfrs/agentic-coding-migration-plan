#!/bin/bash
source .venv/bin/activate
mkdocs serve --config-file mkdocs.en.yml --dev-addr=0.0.0.0:8001
