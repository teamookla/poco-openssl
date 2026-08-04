#!/usr/bin/env bash
# Host-side wrapper: delegates the OpenSSL build into a FreeBSD jail (fbsd14 /
# fbsd15) on the freebsd-jail agent.
#
# Modelled on SharedSuite's build/jenkins_freebsd_jail_build.sh, but kept
# repo-local because that script assumes things this repo doesn't have: it
# hardcodes ./jenkins.sh as the in-jail entry point (there is no jenkins.sh
# here - the build is inline in Jenkinsfile-Native) and it only rsyncs
# test-reports back out. What has to come back here is the DESTDIR install
# tree, since Jenkinsfile-Native tars it up and pushes it to S3 on the host.
#
# .git is excluded from the copy for speed; nothing in the build reads it.

set -Eeuo pipefail

: "${FREEBSD_JAIL:?Need to set FREEBSD_JAIL (e.g. fbsd14, fbsd15)}"
: "${PLATFORM:?Need to set PLATFORM (e.g. freebsd14-x86_64)}"
: "${OPENSSL:?Need to set OPENSSL (e.g. openssl-3.5.5)}"
: "${WORKSPACE:?Need to set WORKSPACE}"

# Jenkins already gives each stage its own workspace dir (see the ws() call in
# Jenkinsfile-Native), so reusing that name keeps concurrent builds targeting
# the same jail from clobbering each other.
JAIL_WORKSPACE="$(basename "$WORKSPACE")"
JAIL_ROOT="/jails/${FREEBSD_JAIL}/workspace/${JAIL_WORKSPACE}"
JAIL_WORKSPACE_PATH="/workspace/${JAIL_WORKSPACE}"

echo "=== FreeBSD jail info ==="
echo "Jail: ${FREEBSD_JAIL}"
echo "Jail workspace: ${JAIL_ROOT}"
sudo jls -j "$FREEBSD_JAIL" || echo "jls failed for jail ${FREEBSD_JAIL}"
sudo jexec "$FREEBSD_JAIL" uname -a || echo "uname inside jail ${FREEBSD_JAIL} failed"
echo "=========================="

sudo mkdir -p "/jails/${FREEBSD_JAIL}/workspace"
sudo rsync -a --delete --exclude=.git "${WORKSPACE}/" "${JAIL_ROOT}/"
sudo chown -R root:wheel "${JAIL_ROOT}"

STATUS=0
sudo jexec "$FREEBSD_JAIL" env \
    "PLATFORM=${PLATFORM}" \
    "OPENSSL=${OPENSSL}" \
    sh -c "cd ${JAIL_WORKSPACE_PATH} && ./build-freebsd.sh" || STATUS=$?

if [[ $STATUS -eq 0 ]]; then
    # Bring the DESTDIR install tree back so the Jenkinsfile can tar/upload it.
    sudo rsync -a --delete "${JAIL_ROOT}/${OPENSSL}/${OPENSSL}/" "${WORKSPACE}/${OPENSSL}/${OPENSSL}/"
    sudo chown -R "$(id -u):$(id -g)" "${WORKSPACE}/${OPENSSL}/${OPENSSL}"
fi

exit $STATUS
