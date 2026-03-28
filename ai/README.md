# AI & Machine Learning

This directory contains services for running large language models (LLMs) and AI workloads locally in the homelab.

## Services Overview

### Local LLM

- **[Ollama + Open WebUI](./ollama-openwebui/README.md)** - Run large language models locally with Ollama and interact with them through a user-friendly web interface

### Hybrid / Experimental

- **[Ollama + Open WebUI (AWS Hybrid)](./ollama-aws-hybrid/README.md)** - Experimental setup that exposes a local Ollama instance to an Open WebUI frontend running on AWS EC2 via a WireGuard tunnel through Gluetun. See that README for the architecture details and current status.

## Choosing a Setup

| Use Case | Setup |
|---|---|
| Local access only | `ollama-openwebui` |
| Remote/internet access | `ollama-aws-hybrid` (experimental) |
