#!/usr/bin/env bash

LOCAL_DIR=$(dirname "$0")
source "${LOCAL_DIR}/envrc"

case "${FLUX_BOOTSTRAP_METHOD}" in
git)
  flux bootstrap git --url "${FLUX_GIT_REPOSITORY}" \
    --path "${CLUSTER_NAME}" || exit $?
  ;;
github)
  flux bootstrap github --owner "${FLUX_GIT_OWNER}" \
    --repository "${FLUX_GIT_REPOSITORY}" \
    --path "${CLUSTER_NAME}" --personal || exit $?
  ;;
gitlab)
  flux bootstrap gitlab --owner "${FLUX_GIT_OWNER}" \
    --repository "${FLUX_GIT_REPOSITORY}" \
    --path "${CLUSTER_NAME}" --token-auth || exit $?
  ;;
*)
  echo >&2 "Only git, github, gitlab are supported"
  exit 1
  ;;
esac

# Add sops secret key into k3s cluster
if kubectl -n flux-system get secret sops-age; then
  kubectl -n flux-system create secret generic sops-age \
    "--from-file=keys.agekey=${SOPS_PATH}/age.key" || exit $?
fi

# Add decryption option to flux so that it can decrypt secrets
if grep -w decryption "${CLUSTER_NAME}/flux-system/gotk-sync.yaml"; then
  cat <<EOF >>"${CLUSTER_NAME}/flux-system/gotk-sync.yaml"
  decryption:
    provider: sops
    secretRef:
      name: sops-age
EOF

  kubectl apply -k "${CLUSTER_NAME}/flux-system" || exit $?
fi
