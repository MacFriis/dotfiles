---
name: cicd-selfhosted
description: GitHub Actions CI/CD patterns for self-hosted runners with zero-downtime deployment via atomic symlink swaps. Use when creating or modifying GitHub Actions workflows, setting up new project deployments, writing systemd service files, or configuring runner labels. Also check the infrastructure repo at /Users/perfriis/Developer/FriisConsult/infrastructure/ for the latest workflow templates.
---

# GitHub Actions CI/CD (Self-Hosted Runners)

Standard pattern for deploying backend/web services to self-hosted Linux runners with zero-downtime symlink-based releases.

**Before changes:** check `/Users/perfriis/Developer/FriisConsult/infrastructure/deployment-standards.md` for the latest workflow template and reference existing project workflows for consistency.

## Runner Labels

Use **project labels**, not server names — lets you move a project to another server by re-tagging the runner.

```yaml
# Correct
runs-on: [self-hosted, myproject]

# Wrong — hardcoded server
runs-on: [self-hosted, jackson]
```

Standard label vocabulary:
- Base: `self-hosted`, `Linux`, `X64`
- Server: `jackson`, `madison`, `jefferson`, etc.
- .NET version: `dotnet9`, `dotnet10`
- CPU: `amd`, `intel`
- Features: `docker`, `rabbitmq`, `mariadb`, `haproxy`
- Projects: `mtazamo`, `crewcast`, `naviblind`, etc.

## Deployment Folder Structure

All projects follow `/srv/{project}/{component}/` with atomic symlink swaps:

```
/srv/{project}/
├── .env                    # Secrets (0600, www-data) — MANUAL setup
├── keys/                   # API keys, certificates — MANUAL setup
│   └── AuthKey.p8
├── api/
│   ├── releases/20251227-153000/
│   └── current -> releases/20251227-153000
├── worker/
│   ├── releases/20251227-153000/
│   └── current -> releases/20251227-153000
└── web/
    ├── releases/20251227-153000/
    └── current -> releases/20251227-153000
```

Deploy: extract new release into `releases/{timestamp}/`, then atomically swap the `current` symlink.

## Workflow: Auto-Setup Infrastructure

CI should create folders and install systemd units on first deploy:

```yaml
- name: Setup infrastructure
  run: |
    sudo mkdir -p /srv/myproject/api/releases
    sudo mkdir -p /srv/myproject/keys
    sudo chown -R www-data:www-data /srv/myproject/api

    # Install/update systemd unit only if changed
    if ! diff -q deploy/systemd/myproject.api.service /etc/systemd/system/myproject.api.service > /dev/null 2>&1; then
      sudo cp deploy/systemd/myproject.api.service /etc/systemd/system/
      sudo systemctl daemon-reload
      echo "Installed/updated myproject.api.service"
    fi

    sudo systemctl enable myproject.api.service 2>/dev/null || true

    if [ ! -f /srv/myproject/.env ]; then
      echo "::warning::Missing /srv/myproject/.env — create manually"
    fi
```

## Required Files in Repo

```
deploy/
├── systemd/
│   ├── myproject.api.service
│   └── myproject.worker.service
├── nginx/
│   └── myproject.com.conf
└── env/
    └── myproject.env.example    # Template for the manual /srv/myproject/.env
```

## Systemd Service Template

```ini
[Unit]
Description=MyProject API
After=network.target mariadb.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/srv/myproject/api/current
ExecStart=/usr/bin/dotnet /srv/myproject/api/current/MyProject.dll
Restart=always
RestartSec=10

# Shared .env across api/worker/web
EnvironmentFile=/srv/myproject/.env
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/srv/myproject/api

[Install]
WantedBy=multi-user.target
```

## Manual Steps for a New Server

CI handles everything except:

1. Add the project label to the runner (e.g., `myproject`)
2. Create `/srv/myproject/.env` from `deploy/env/myproject.env.example`
3. Copy keys/certificates into `/srv/myproject/keys/`
4. If web-facing, set up SSL on the reverse proxy (madison + monroe) via certbot — see infrastructure repo
