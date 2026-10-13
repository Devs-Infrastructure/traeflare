FROM python:3.14-alpine@sha256:f6a589d43c42b9e7f7dc67a12d37132491f362859a5d750607710cc56da3bc72

ARG VERSION="1.0.0"

LABEL org.opencontainers.image.title="Traeflare" \
      org.opencontainers.image.description="Automatically manage Cloudflare DNS records for services exposed by Traefik" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/itspasha/traeflare" \
      org.opencontainers.image.url="https://github.com/itspasha/traeflare" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="itspasha"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LOG_TYPE=CONSOLE

WORKDIR /app

COPY requirements.txt ./
RUN pip install --upgrade --no-cache-dir --requirement requirements.txt && \
    pip uninstall --yes pip setuptools

COPY install/usr/sbin/traeflare /usr/local/bin/traeflare

ENTRYPOINT ["python3", "/usr/local/bin/traeflare"]
