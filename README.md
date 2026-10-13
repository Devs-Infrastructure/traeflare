# Traeflare

[![GitHub release](https://img.shields.io/github/v/release/devs-infrastructure/traeflare?style=flat-square)](https://github.com/devs-infrastructure/traeflare/releases/latest)
[![Build](https://img.shields.io/github/actions/workflow/status/devs-infrastructure/traeflare/build.yml?branch=main&style=flat-square)](https://github.com/devs-infrastructure/traeflare/actions/workflows/build.yml)
[![Container](https://img.shields.io/badge/ghcr.io-container-blue?logo=docker&style=flat-square)](https://github.com/devs-infrastructure/traeflare/pkgs/container/traeflare)

Automatically creates or updates Cloudflare DNS records for services exposed by [Traefik](https://github.com/traefik/traefik).

This repository is the maintained home of the project beginning with version `1.0.0`.

## Quick start

```yaml
services:
  traeflare:
    image: ghcr.io/devs-infrastructure/traeflare:1
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
docker pull ghcr.io/devs-infrastructure/traeflare:1
```

Or build it locally:

```bash
docker build --build-arg VERSION=dev -t traeflare:dev .
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

## Releases

Every merge to `main` publishes a release automatically. Version numbers follow [Semantic Versioning](https://semver.org/) from Conventional Commit titles: `feat!:` (or a `BREAKING CHANGE`) increments the major version, `feat:` increments the minor version, and every other merge increments the patch version. There is no separate release pull request.

Each GitHub release includes generated notes, a standalone `traeflare-<version>` script, a source bundle with its pinned Python requirements, and `SHA256SUMS`. It also publishes a multi-platform image for `linux/amd64` and `linux/arm64` with four convenient tags:

```text
ghcr.io/devs-infrastructure/traeflare:1.2.3  # immutable release
ghcr.io/devs-infrastructure/traeflare:1.2    # latest patch in the 1.2 line
ghcr.io/devs-infrastructure/traeflare:1      # latest compatible major
ghcr.io/devs-infrastructure/traeflare:latest # latest stable release
```

Release notes are generated from the merged pull requests and published on the [GitHub Releases page](https://github.com/devs-infrastructure/traeflare/releases). For reproducible deployments, pin the full version or image digest. Published images include an SBOM and signed build provenance; downloadable files have GitHub artifact attestations and SHA-256 checksums.

Dependencies are pinned in [`requirements.txt`](requirements.txt). Pull requests and main-branch builds scan the container for fixed high and critical vulnerabilities, and releases are published only after the same scan passes.

## Support

Use [GitHub Issues](https://github.com/devs-infrastructure/traeflare/issues) for reproducible bugs and [GitHub Discussions](https://github.com/devs-infrastructure/traeflare/discussions) for usage questions.

## License

MIT. See [LICENSE](LICENSE).
