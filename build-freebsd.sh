#!/usr/bin/env bash
# In-jail OpenSSL build for the FreeBSD 14/15 jails.
#
# Runs *inside* the jail, launched by freebsd-jail-build.sh. Everything this
# repo used to do inline in Jenkinsfile-Native's `sh` block for native unix
# builds lives here instead, because the jail needs a single entry point to
# jexec into.
#
# PLATFORM decides native vs. cross:
#   freebsd1{4,5}-x86_64  -> native ./config, same as the old freebsd13 builder
#   freebsd1{4,5}-arm64   -> cross build against the toolchain baked into the
#                            jail at /opt/cross/arm64 (wrappers arm64-cc /
#                            arm64-c++ on PATH), matching SharedSuite's
#                            cmake/toolchains/freebsd-arm64.cmake

set -Eeuxo pipefail

: "${PLATFORM:?Need to set PLATFORM (e.g. freebsd14-x86_64)}"
: "${OPENSSL:?Need to set OPENSSL (e.g. openssl-3.5.5)}"

# Configure flags shared with the non-FreeBSD builds in Jenkinsfile-Native.
# Keep these in sync with the inline `./config` there.
CONFIGURE_FLAGS=(
    --prefix=/usr
    --openssldir=/usr/lib/ssl
    --libdir=lib
    no-ssl
    no-tests
    no-ui-console
    no-unit-test
)

cd "${OPENSSL}"

# The DESTDIR install tree from a previous run in a reused workspace.
rm -rf "./${OPENSSL}"

case "$PLATFORM" in
    *-arm64)
        export CC=arm64-cc
        export CXX=arm64-c++
        ./Configure BSD-aarch64 "${CONFIGURE_FLAGS[@]}"
        ;;
    *)
        ./config "${CONFIGURE_FLAGS[@]}"
        ;;
esac

make -j"$(sysctl -n hw.ncpu)"
make DESTDIR="./${OPENSSL}" install_ssldirs install_sw
