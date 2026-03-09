#!/bin/bash
source .venv/bin/activate
mkdocs serve --config-file mkdocs.ar.yml --dev-addr=0.0.0.0:8002
