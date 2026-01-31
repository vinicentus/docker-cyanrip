# syntax=docker/dockerfile:1.9.0
FROM alpine:3.20 AS builder
ARG cyanrip_version=v0.9.3.1
WORKDIR /tmp
RUN <<EOF
#!/bin/sh
set -eu

apk add --no-cache \
  ffmpeg-libs \
  libcdio \
  libcdio-paranoia \
  libcurl \
  libmusicbrainz \
  util-linux

apk add --no-cache --virtual .build-deps \
  cmake \
  curl \
  curl-dev \
  ffmpeg-dev \
  gcc \
  libcdio-dev \
  libcdio-paranoia-dev \
  libmusicbrainz-dev \
  meson \
  musl-dev \
  pkgconfig

curl -fsSL \
  "https://github.com/cyanreg/cyanrip/archive/refs/tags/${cyanrip_version}.tar.gz" |
  tar xz --strip=1
sed -i 's/>= 10\.2/>= 2.0/' src/meson.build
meson build
ninja -C build install

apk del --purge \
  alpine-baselayout \
  alpine-keys \
  apk-tools \
  busybox \
  .build-deps

# Keep script(1) for entrypoint (PTY line normalization); nuke the rest of /usr/bin
cp /usr/bin/script /usr/local/bin/script
rm -rf /usr/bin /usr/sbin /lib/apk
EOF

FROM scratch AS cyanrip
COPY --from=builder /lib /lib
COPY --from=builder /usr /usr
COPY entrypoint.sh /wrapper.sh

LABEL maintainer="https://github.com/eq76/docker-cyanrip"
ENTRYPOINT [ "/wrapper.sh" ]
CMD [ "-h" ]
