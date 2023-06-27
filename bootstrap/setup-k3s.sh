#!/bin/bash

K3S_VERSION=${K3S_VERSION:-v1.27.2+k3s1}

K3S_USER=${K3S_USER:-root}

K3S_SERVER=${K3S_SERVER:-}
K3S_SERVERS_TO_JOIN=${K3S_SERVERS_TO_JOIN:-}
K3S_AGENTS=${K3S_AGENTS:-}

if [ -n "$K3S_CLUSTER_CIDR_V4" ] && [ -n "$K3S_CLUSTER_CIDR_V6" ]; then
  K3S_CLUSTER_CIDR="${K3S_CLUSTER_CIDR_V4},${K3S_CLUSTER_CIDR_V6}"
  K3S_SERVICE_CIDR="${K3S_SERVICE_CIDR_V4},${K3S_SERVICE_CIDR_V6}"
elif [ -n "$K3S_CLUSTER_CIDR_V4" ]; then
  K3S_CLUSTER_CIDR="${K3S_CLUSTER_CIDR_V4}"
  K3S_SERVICE_CIDR="${K3S_SERVICE_CIDR_V4}"
elif [ -n "$K3S_CLUSTER_CIDR_V6" ]; then
  K3S_CLUSTER_CIDR="${K3S_CLUSTER_CIDR_V6}"
  K3S_SERVICE_CIDR="${K3S_SERVICE_CIDR_V6}"
else
  K3S_CLUSTER_CIDR=10.42.0.0/16
  K3S_SERVICE_CIDR=10.43.0.0/16
fi

K3S_EXTRA_ARGS="$K3S_EXTRA_ARGS --flannel-backend=wireguard-native --disable=servicelb,traefik --cluster-cidr=${K3S_CLUSTER_CIDR} --service-cidr=${K3S_SERVICE_CIDR}"

k3sup install \
  --cluster \
  --user "${K3S_USER}" \
  --host "${K3S_SERVER}" \
  --k3s-extra-args "${K3S_EXTRA_ARGS}" \
  --k3s-version "${K3S_VERSION}" || exit $?

if [ -n "${K3S_SERVERS_TO_JOIN}" ]; then
  for server_to_join in "${K3S_SERVERS_TO_JOIN[@]}"; do
    k3sup join \
      --server \
      --server_user "${K3S_USER}" \
      --server_host "${K3S_SERVER}" \
      --user "${K3S_USER}" \
      --host "${server_to_join}" \
      --k3s-extra-args "${K3S_EXTRA_ARGS}" \
      --k3s-version "${K3S_VERSION}" || exit $?
  done
fi

if [ -n "${K3S_AGENTS}" ]; then
  for agent in "${K3S_AGENTS[@]}"; do
    k3sup join \
      --server_user "${K3S_USER}" \
      --server_host "${K3S_SERVER}" \
      --user "${K3S_USER}" \
      --host "${agent}" \
      --k3s-extra-args "${K3S_EXTRA_ARGS}" \
      --k3s-version "${K3S_VERSION}" || exit $?
  done
fi
