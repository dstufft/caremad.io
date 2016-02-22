FROM alpine:latest

ENV SIMP_LE_HASH 8f258bc098a84b7a20c2732536d0740244d814f7
ENV SIMP_LE_SHA256 118da1fe3c6f40410d72dcba819a4634b7f1a965497451e3706b9c7e9eee1b590fa20a30699b544d3b4ca0a27a605b5568d2e2c7a490c99da0c793c62f144c0a

RUN set -x \
    && apk --no-cache add python3 openssl libffi \
    && apk --no-cache add --virtual build-dependencies perl wget ca-certificates build-base openssl-dev python3-dev libffi-dev \
    && python3 -m ensurepip \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && wget -q https://github.com/kuba/simp_le/archive/${SIMP_LE_HASH}.zip -O /tmp/simp_le.zip \
    && echo "${SIMP_LE_SHA256}  /tmp/simp_le.zip" | shasum -a 512 -c - \
    && pip install /tmp/simp_le.zip \
    && apk del build-dependencies \
    && rm -rf ~/.cache/

ADD initial-cert /usr/bin/initial-cert

ADD crontab /var/spool/cron/crontabs/root

ADD renew-certs /usr/bin/renew-certs

ADD domains /etc/lets-encrypt/domains

CMD ["crond", "-d", "8", "-f"]
