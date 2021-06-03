#!/usr/bin/env bash
# /usr/local/bin/kustomize-wrapper.sh
# ensure file is executable
# helm install CHART REPO/CHART --post-renderer kustomize-wrapper.sh
# function helm () { HELM=`which helm`; [[ $1 =~ ^install|upgrade$ ]] && $HELM $@ --post-renderer kustomize-wrapper.sh || $HELM $@; }

function cleanup () {
	kustomize edit remove resource "${TMPFILE}"
	rm -f "${TMPFILE}"
}

# Create temporary file for processing helm output
TMPFILE=$(mktemp kustomize.XXXXXX)
# On script exit clean up workspace
trap cleanup EXIT

# Sanity checks and initialisation
[ -f kustomization.yaml ] || kustomize create

# Stream stdin to temporary file for kustomize processing
cat <&0 >"${TMPFILE}"
# Add a temporary resource entry for the Helm resource definitions
kustomize edit add resource "${TMPFILE}"
# Run the Kustomize build operation
kustomize build .
