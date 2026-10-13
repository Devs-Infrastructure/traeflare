# Traeflare

[![GitHub release](https://img.shields.io/github/v/tag/itspasha/traeflare?style=flat-square)](https://github.com/itspasha/traeflare/releases/latest)
[![Build](https://img.shields.io/github/actions/workflow/status/itspasha/traeflare/build.yml?branch=main&style=flat-square)](https://github.com/itspasha/traeflare/actions/workflows/build.yml)
[![Container](https://img.shields.io/badge/ghcr.io-container-blue?logo=docker&style=flat-square)](https://github.com/itspasha/traeflare/pkgs/container/traeflare)

Automatically creates or updates Cloudflare DNS records for services exposed by [Traefik](https://github.com/traefik/traefik).

This repository is the maintained home of the project beginning with version `1.0.0`.

## Quick start

```yaml
services:
  traeflare:
    image: ghcr.io/itspasha/traeflare:1.0.0
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      CF_TOKEN: ${CF_TOKEN}
      TARGET_DOMAIN: host.example.org
      DOMAIN1: example.org
      DOMAIN1_ZONE_ID: ${DOMAIN1_ZONE_ID}
    restart: unless-stopped
```

Use a scoped Cloudflare API token with only `Zone:DNS:Edit` and `Zone:Zone:Read` permissions for the zones the companion manages. Do not commit tokens or zone IDs to the repository.

The Docker socket grants extensive control over the host even when mounted read-only. For a hardened deployment, expose only the required read endpoints through a Docker socket proxy and set `DOCKER_HOST` to that proxy.

## Installation

Pull the published image:

```bash
docker pull ghcr.io/itspasha/traeflare:1.0.0
```

Or build it locally:

```bash
docker build --build-arg VERSION=1.0.0 -t traeflare:1.0.0 .
```

Published images support `linux/amd64` and `linux/arm64`.

## Configuration

### Core options

| Variable | Description | Default |
| --- | --- | --- |
| `CF_TOKEN` | Scoped API token, or global API key when `CF_EMAIL` is also set | required |
| `CF_EMAIL` | Account email; leave unset when using a scoped token | unset |
| `TARGET_DOMAIN` | Default DNS record destination | required |
| `DOMAIN1` | First managed zone name | required |
| `DOMAIN1_ZONE_ID` | Cloudflare zone ID for `DOMAIN1` | required |
| `DOMAIN<n>` | Additional managed zone | unset |
| `DOMAIN<n>_ZONE_ID` | Zone ID for an additional zone | unset |
| `DOMAIN<n>_PROXIED` | Enable Cloudflare proxying for the zone | `FALSE` |
| `DOMAIN<n>_TTL` | Zone-specific TTL | value of `DEFAULT_TTL` |
| `DOMAIN<n>_TARGET_DOMAIN` | Override `TARGET_DOMAIN` for the zone | unset |
| `DOMAIN<n>_COMMENT` | Comment stored with managed records | unset |
| `DOMAIN<n>_EXCLUDED_SUB_DOMAINS` | Comma-separated subdomain trees to ignore | unset |
| `RC_TYPE` | DNS record type, such as `CNAME`, `A`, or `AAAA` | `CNAME` |
| `DEFAULT_TTL` | TTL in seconds; `1` selects Cloudflare automatic TTL | `1` |
| `REFRESH_ENTRIES` | Rewrite records even when their content is unchanged | `FALSE` |
| `DRY_RUN` | Log planned changes without writing them | `FALSE` |

`CF_TOKEN`, `CF_EMAIL`, and every `DOMAIN<n>_ZONE_ID` also support the conventional `<VARIABLE>_FILE` form for Docker secrets.

### Docker discovery

| Variable | Description | Default |
| --- | --- | --- |
| `ENABLE_DOCKER_POLL` | Discover routes from Docker | `TRUE` |
| `DOCKER_HOST` | Docker daemon or socket-proxy endpoint | Docker SDK default |
| `DOCKER_SWARM_MODE` | Discover Docker Swarm services | `FALSE` |
| `TRAEFIK_VERSION` | Traefik label format (`1` or `2`) | `2` |
| `TRAEFIK_FILTER_LABEL` | Label used to restrict discovered workloads | `traefik.constraint` |
| `TRAEFIK_FILTER` | Regular expression the filter-label value must match | unset |

For Traefik 2 and 3, routes are read from labels such as:

```yaml
labels:
  traefik.http.routers.example.rule: Host(`example.org`) || Host(`www.example.org`)
```

### Traefik API polling

Polling can be used with or without Docker discovery.

| Variable | Description | Default |
| --- | --- | --- |
| `ENABLE_TRAEFIK_POLL` | Poll the Traefik HTTP API | `FALSE` |
| `TRAEFIK_POLL_URL` | Traefik API base URL | unset |
| `TRAEFIK_POLL_SECONDS` | Seconds between polls | `60` |
| `TRAEFIK_INCLUDED_HOST<n>` | Regular expression for included hosts | `.*` |
| `TRAEFIK_EXCLUDED_HOST<n>` | Regular expression for excluded hosts | unset |

To use API-only discovery, set `ENABLE_DOCKER_POLL=FALSE`, `ENABLE_TRAEFIK_POLL=TRUE`, and `TRAEFIK_POLL_URL=http://traefik:8080`.

### Logging

| Variable | Description | Default |
| --- | --- | --- |
| `LOG_LEVEL` | `INFO`, `VERBOSE`, or `DEBUG` | `INFO` |
| `LOG_TYPE` | `CONSOLE`, `FILE`, or `BOTH` | `CONSOLE` |
| `LOG_PATH` | Directory for file logging | `/logs` |
| `LOG_FILE` | Log filename | `traeflare.log` |

Mount a writable volume at `/logs` before selecting `FILE` or `BOTH`.

## Security and releases

Dependencies are pinned in [`requirements.txt`](requirements.txt). Every build scans the container for fixed high and critical vulnerabilities before publishing a multi-platform image to GHCR. Version tags such as `v1.0.0` publish `1.0.0` and `1.0`; builds from `main` publish `latest`.

## Support

Use [GitHub Issues](https://github.com/itspasha/traeflare/issues) for reproducible bugs and [GitHub Discussions](https://github.com/itspasha/traeflare/discussions) for usage questions.

## License

MIT. See [LICENSE](LICENSE).
