#!/bin/bash

TRAEFIK_VERSION=${TRAEFIK_VERSION:-2.10.3}

LOCAL_DIR=$(dirname "$0")
CONTENT_URL=https://raw.githubusercontent.com/traefik/traefik/v${TRAEFIK_VERSION}/docs/content/reference/dynamic-configuration

INGRESS_CONFIGURATIONS=(kubernetes-crd-definition-v1.yml
	kubernetes-crd-rbac.yml)
GATEWAY_CONFIGURATIONS=(gateway.networking.k8s.io_gatewayclasses.yaml
	gateway.networking.k8s.io_gateways.yaml
	gateway.networking.k8s.io_httproutes.yaml
	gateway.networking.k8s.io_tcproutes.yaml
	gateway.networking.k8s.io_tlsroutes.yaml
	kubernetes-gateway-rbac.yml)

pushd "${LOCAL_DIR}/origin" || exit $?

# ingress configurations
for config in "${INGRESS_CONFIGURATIONS[@]}"; do
	echo "Download ingress configuration ${config} ..."
	wget -q -O "${config}" "${CONTENT_URL}/${config}" || exit $?
done

# gateway configurations
for config in "${GATEWAY_CONFIGURATIONS[@]}"; do
	echo "Download gateway configuration ${config} ..."
	wget -q -O "${config}" "${CONTENT_URL}/${config}" || exit $?
done

popd || exit $?

pushd "$LOCAL_DIR" || exit $?

sed -i 's/traefik:v[0-9.]\+/traefik:v'"$TRAEFIK_VERSION/g" traefik.yml

popd || exit $?
