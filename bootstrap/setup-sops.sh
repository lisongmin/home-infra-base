#!/bin/bash
# Setup a sops environment in the current directory so that it will
# encrypt the data or stringData fields in the files which end with
# .secret.yml or .secret.yaml

SOPS_PATH=${SOPS_PATH:-~/.config/sops/homelab}
mkdir -p "${SOPS_PATH}"

if [ ! -e "${SOPS_PATH}/age.key" ]; then
  age-keygen -o "${SOPS_PATH}/age.key" || exit $?
fi

if [ ! -e .sops.yaml ]; then
  public_key=$(sed -n 's/^# public key: \(\w\+\)$/\1/p' "${SOPS_PATH}/age.key")

  cat <<EOF >.sops.yaml
  ---
  creation_rules:
  - encrypted_regex: '^(data|stringData)$'
    path_regex: '.*\/.*\.secret\.ya?ml$'
    age: >-
      ${public_key}
EOF
fi
