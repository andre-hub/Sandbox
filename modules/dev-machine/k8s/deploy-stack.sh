#!/usr/bin/env bash
# =====================================================================
# deploy-stack.sh - Generic local dev infrastructure stack deployer
#
# Starts Minikube, installs the Envoy Gateway + the Prometheus/Grafana
# monitoring stack (Helm) and deploys the generic infra services
# (MongoDB, RabbitMQ, Mongo Express) via `kubectl apply -k k8s/`.
#
# Company-independent. No application code is deployed.
#
# Usage:  deploy-stack.sh [PACKAGE_DIR]
#         PACKAGE_DIR defaults to the directory containing this script's k8s folder.
# =====================================================================
set -euo pipefail

# --- Locate package + config -----------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="${1:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
K8S_DIR="${SCRIPT_DIR}"
CONFIG_INI="${PKG_DIR}/config.ini"
export -n APP_USERNAME APP_PASSWORD 2>/dev/null || true

info()    { echo -e "\033[0;36m[INFO]\033[0m  $*"; }
ok()      { echo -e "\033[0;32m[OK]\033[0m    $*"; }
warn()    { echo -e "\033[0;33m[WARN]\033[0m  $*"; }
err()     { echo -e "\033[0;31m[ERROR]\033[0m $*"; }

cfg() {
    local key="$1" def="${2:-}"
    local val=""
    if [[ -f "${CONFIG_INI}" ]]; then
        val="$(awk -F= -v key="${key}" '$1 == key { sub(/^[^=]*=/, ""); sub(/\r$/, ""); print; exit }' "${CONFIG_INI}")"
    fi
    printf '%s' "${val:-$def}"
}

legacy_value() {
    local result="" candidate="" key=""
    for key in "$@"; do
        candidate="$(cfg "${key}")"
        [[ -z "${candidate}" ]] && continue
        [[ -z "${result}" || "${result}" == "${candidate}" ]] || return 1
        result="${candidate}"
    done
    printf '%s' "${result}"
}

# --- Configuration (with safe generic defaults) ----------------------
NAMESPACE="$(cfg NAMESPACE dev-infra)"
K8S_VERSION="$(cfg KUBERNETES_VERSION v1.30.0)"; [[ "${K8S_VERSION}" == v* ]] || K8S_VERSION="v${K8S_VERSION}"
MINIKUBE_DRIVER="$(cfg MINIKUBE_DRIVER docker)"
MINIKUBE_MEMORY="$(cfg MINIKUBE_MEMORY 8192)"
MINIKUBE_CPUS="$(cfg MINIKUBE_CPUS 4)"
ENVOY_GATEWAY_VERSION="$(cfg ENVOY_GATEWAY_VERSION v1.2.1)"

APP_USERNAME="$(cfg APP_USERNAME)"
APP_PASSWORD="$(cfg APP_PASSWORD)"
export -n APP_USERNAME APP_PASSWORD
if [[ -z "${APP_USERNAME}" ]]; then
    APP_USERNAME="$(legacy_value MONGODB_USER RABBITMQ_USER)" || { err "Legacy usernames differ."; exit 1; }
fi
if [[ -z "${APP_PASSWORD}" ]]; then
    APP_PASSWORD="$(legacy_value MONGODB_PASSWORD RABBITMQ_PASSWORD GRAFANA_PASSWORD)" || { err "Legacy passwords differ."; exit 1; }
fi
export -n APP_USERNAME APP_PASSWORD
[[ "${APP_USERNAME}" =~ ^[a-z][a-z0-9_-]{2,31}$ ]] || { err "Credential configuration is missing or invalid."; exit 1; }
[[ ${#APP_PASSWORD} -ge 12 && ${#APP_PASSWORD} -le 256 ]] || { err "Credential configuration is missing or invalid."; exit 1; }
[[ "${APP_PASSWORD}" != *$'\r'* && "${APP_PASSWORD}" != *$'\n'* ]] || { err "Credential configuration is invalid."; exit 1; }
[[ "${NAMESPACE}" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]] || { err "Namespace is invalid."; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || { err "'$1' not found in PATH – please install it first."; return 1; }; }

# --- Minikube --------------------------------------------------------
start_minikube() {
    require minikube || return 1
    require kubectl  || return 1
    if minikube status >/dev/null 2>&1; then
        info "Minikube already running"
        return 0
    fi
    info "Starting Minikube ${K8S_VERSION} (driver=${MINIKUBE_DRIVER}, mem=${MINIKUBE_MEMORY}, cpus=${MINIKUBE_CPUS})..."
    minikube start --kubernetes-version="${K8S_VERSION}" \
        --driver="${MINIKUBE_DRIVER}" \
        --memory="${MINIKUBE_MEMORY}" --cpus="${MINIKUBE_CPUS}"
    minikube addons enable metrics-server >/dev/null 2>&1 || true
    ok "Minikube started ($(minikube ip 2>/dev/null || echo '?'))"
}

# --- Envoy Gateway ---------------------------------------------------
install_envoy_gateway() {
    if kubectl get crd gateways.gateway.networking.k8s.io >/dev/null 2>&1; then
        info "Gateway API already installed"
    else
        info "Installing Envoy Gateway ${ENVOY_GATEWAY_VERSION}..."
        kubectl apply --server-side -f \
            "https://github.com/envoyproxy/gateway/releases/download/${ENVOY_GATEWAY_VERSION}/install.yaml"
    fi
    kubectl wait deployment/envoy-gateway -n envoy-gateway-system \
        --for=condition=Available --timeout=300s || warn "Envoy Gateway not ready yet"
}

# --- Monitoring (Helm) -----------------------------------------------
install_monitoring() {
    require helm || { warn "helm missing – skipping monitoring stack"; return 0; }
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
    helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
    helm repo update >/dev/null 2>&1 || true

    info "Installing kube-prometheus-stack..."
    helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring --create-namespace \
        -f "${K8S_DIR}/monitoring/kube-prometheus-values.yaml" \
        --wait --timeout=5m
    ok "kube-prometheus-stack ready"

    info "Installing Grafana Operator..."
    helm upgrade --install grafana-operator grafana/grafana-operator \
        --namespace monitoring --wait --timeout=5m
    ok "Grafana Operator ready"

    info "Creating Grafana admin secret..."
    {
        printf '%s\n' 'apiVersion: v1' 'kind: Secret' 'metadata:' '  name: grafana-admin-secret' '  namespace: monitoring' 'type: Opaque' 'data:'
        printf '  admin-user: '; printf '%s' "${APP_USERNAME}" | base64 | tr -d '\n'; printf '\n'
        printf '  admin-password: '; printf '%s' "${APP_PASSWORD}" | base64 | tr -d '\n'; printf '\n'
    } | kubectl apply -f - >/dev/null

    info "Installing Loki stack..."
    helm upgrade --install loki grafana/loki-stack \
        --namespace monitoring --set grafana.enabled=false \
        --wait --timeout=5m || warn "Loki stack not ready"
    ok "Monitoring stack deployed"
}

# --- Infra services --------------------------------------------------
deploy_services() {
    kubectl apply -f "${K8S_DIR}/namespace.yaml"

    info "Creating MongoDB + RabbitMQ secrets..."
    {
        printf '%s\n' 'apiVersion: v1' 'kind: Secret' 'metadata:' '  name: mongodb-secret' "  namespace: ${NAMESPACE}" 'type: Opaque' 'data:'
        printf '  MONGO_INITDB_ROOT_USERNAME: '; printf '%s' "${APP_USERNAME}" | base64 | tr -d '\n'; printf '\n'
        printf '  MONGO_INITDB_ROOT_PASSWORD: '; printf '%s' "${APP_PASSWORD}" | base64 | tr -d '\n'; printf '\n'
    } | kubectl apply -f - >/dev/null
    {
        printf '%s\n' 'apiVersion: v1' 'kind: Secret' 'metadata:' '  name: rabbitmq-secret' "  namespace: ${NAMESPACE}" 'type: Opaque' 'data:'
        printf '  RABBITMQ_DEFAULT_USER: '; printf '%s' "${APP_USERNAME}" | base64 | tr -d '\n'; printf '\n'
        printf '  RABBITMQ_DEFAULT_PASS: '; printf '%s' "${APP_PASSWORD}" | base64 | tr -d '\n'; printf '\n'
    } | kubectl apply -f - >/dev/null

    unset APP_USERNAME APP_PASSWORD

    info "Deploying generic infra stack (kubectl apply -k)..."
    kubectl apply -k "${K8S_DIR}"

    info "Waiting for pods (max 5 min)..."
    for app in mongodb rabbitmq mongo-express; do
        if kubectl wait pod -l "app=${app}" -n "${NAMESPACE}" \
            --for=condition=Ready --timeout=300s 2>/dev/null; then
            ok "${app} ready"
        else
            warn "${app} not ready yet"
        fi
    done
}

show_summary() {
    echo ""
    ok "Generic dev infrastructure stack is up!"
    echo "  Hostname access (requires /etc/hosts -> minikube ip, and a gateway port-forward):"
    echo "    http://rabbitmq.local       (credentials in rabbitmq-secret)"
    echo "    http://mongodb.local        (Mongo Express UI)"
    echo "    http://mongo-express.local  (Mongo Express UI)"
    echo "    http://grafana.local        (credentials in grafana-admin-secret)"
    echo "    http://prometheus.local     (Prometheus)"
    echo "    http://loki.local           (Loki)"
    echo "    http://alertmanager.local   (Alertmanager)"
    echo ""
    echo "  Port-forward examples:"
    echo "    kubectl port-forward svc/mongodb-service 27017:27017 -n ${NAMESPACE}"
    echo "    kubectl port-forward svc/rabbitmq-service 5672:5672 -n ${NAMESPACE}"
    echo "    kubectl port-forward svc/grafana-service 3000:3000 -n monitoring"
}

main() {
    echo "=== Local dev infrastructure stack deployment ==="
    start_minikube
    install_envoy_gateway
    install_monitoring
    deploy_services
    show_summary
}

main "$@"
