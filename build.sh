#!/bin/bash
source .venv/bin/activate
mkdocs build --config-file mkdocs.en.yml
mkdocs build --config-file mkdocs.ar.yml
