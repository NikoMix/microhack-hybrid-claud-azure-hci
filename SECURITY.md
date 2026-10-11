# Security policy

This repository contains **training material** — no production systems or customer data.

## Reporting a vulnerability

If you find a security issue in the lab code (e.g. an insecure default in the Terraform, a script that mishandles credentials, or a leaked secret), please **open a private security advisory** via the repository's **Security → Advisories** tab, or open a regular issue if it is low-risk and non-sensitive.

## Secrets

- Never commit secrets. The repo is scanned with **gitleaks** in CI and via a pre-commit hook.
- Use `az login` (device code) and Azure managed identities. Do not place credentials in `.tfvars` that are committed — use `*.tfvars.example` placeholders only.

## Lab hygiene

- All lab resources are disposable. **Tear them down** at the end of each delivery (`task destroy:base`).
- Defender for Cloud is enabled during the labs to demonstrate posture management; review and disable plans you no longer need to avoid cost.
