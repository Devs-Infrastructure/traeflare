FROM python:3.15-alpine@sha256:2699b90f4d562a22e2dd076c82f964032f64814204bff36d271a54ba4cc2c7e2

ARG VERSION="dev"

LABEL org.opencontainers.image.title="Traeflare" \
      org.opencontainers.image.description="Automatically manage Cloudflare DNS records for services exposed by Traefik" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/devs-infrastructure/traeflare" \
      org.opencontainers.image.url="https://github.com/devs-infrastructure/traeflare" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="Devs Infrastructure"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LOG_TYPE=CONSOLE

WORKDIR /app

COPY requirements.txt ./
RUN pip install --upgrade --no-cache-dir --requirement requirements.txt && \
    pip uninstall --yes pip setuptools

COPY install/usr/sbin/traeflare /usr/local/bin/traeflare

ENTRYPOINT ["python3", "/usr/local/bin/traeflare"]
