#!/bin/bash

LOCAL_DIR=$(dirname "$0")
source "${LOCAL_DIR}/envrc"

echo "This command will REMOVE THE K3S CLUSTER '${CLUSTER_NAME}'."
read -s -r -n 1 -p "Are you sure to continue?(y/N)" confirm
echo ""
if [ "$confirm" != "y" ]; then
  echo -e "User canceled"
  exit 0
fi

# Uninstall all k3s agents
if [ -n "$K3S_AGENTS" ]; then
  read -ra agents <<<"$K3S_AGENTS"
  for agent in "${agents[@]}"; do
    echo "Uninstall k3s on node $agent"
    ssh "$K3S_USER@$agent" <<EOF || exit $?
  if [ -x /usr/local/bin/k3s-uninstall-agent.sh ]; then
    /usr/local/bin/k3s-uninstall-agent.sh
  fi
EOF
  done
fi

read -ra servers <<<"$K3S_SERVERS_TO_JOIN $K3S_SERVER"
for server in "${servers[@]}"; do
  echo "Uninstall k3s on node $server"
  ssh "$K3S_USER@$server" <<EOF || exit $?
  if [ -x /usr/local/bin/k3s-uninstall.sh ]; then
    /usr/local/bin/k3s-uninstall.sh
  fi
EOF
done
