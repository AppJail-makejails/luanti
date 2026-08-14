ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="Luanti" \
    org.opencontainers.image.description="Near-infinite-world block sandbox game" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/luanti" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/luanti" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install luanti; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

WORKDIR /var/db/minetest

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

VOLUME ["/var/db/minetest"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--config", "/usr/local/etc/minetest.conf"]
