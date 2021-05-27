#!/usr/bin/env bash
# helm install CHART REPO/CHART --post-renderer kustomize-wrapper.sh
# function helm () { HELM=`which helm`; [[ $1 =~ ^install|upgrade$ ]] && $HELM $@ --post-renderer kustomize-wrapper.sh || $HELM $@; }

function cleanup () {
	kustomize edit remove resource "${TMPFILE}"
	rm -f "${TMPFILE}"
}

# Create temporary file for processing helm output
TMPFILE=$(mktemp /tmp/kustomize.XXXXXX)
# On script exit clean up workspace
trap cleanup EXIT

# Sanity checks and initialisation
[ -f kustomization.yaml ] || kustomize create

# Stream stdin to temporary file for kustomize processing
cat <&0 >"${TMPFILE}"

kustomize edit add resource "${TMPFILE}"
kustomize build .
