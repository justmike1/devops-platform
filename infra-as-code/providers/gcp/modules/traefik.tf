resource "kubernetes_namespace" "ingress-ns-traefik" {
  count = var.enable_traefik ? 1 : 0
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik-ingress-controller" {
  count            = var.enable_traefik ? 1 : 0
  name             = "traefik"
  chart            = "traefik"
  version          = "20.8.0"
  repository       = "https://helm.traefik.io/traefik"
  namespace        = kubernetes_namespace.ingress-ns-traefik[count.index].metadata.0.name
  create_namespace = true
  values = [<<EOF
additionalArguments:
  - --ping
  - --ping.entrypoint=web
service:
  annotations:
    cloud.google.com/backend-config: "{\"ports\": {\"80\":\"backendconfig-${google_compute_security_policy.cluster-sec-policy[count.index].name}\"}}"
ingressRoute:
  dashboard:
    enabled: false
providers:
  kubernetesIngress:
    ingressClass: traefik
    publishedService:
      pathOverride: "${kubernetes_namespace.ingress-ns-traefik[count.index].metadata.0.name}/traefik"
      enabled: true
ingressClass:
  isDefaultClass: false
ports:
  traefik:
    healthchecksPort: 8000
  web:
    nodePort: 32080
    forwardedHeaders:
      insecure: true
    proxyProtocol:
      insecure: true
  websecure:
    nodePort: 32443
    forwardedHeaders:
      insecure: true
    proxyProtocol:
      insecure: true
service:
  type: NodePort
logs:
  access:
    enabled: false
    format: json
  general:
    level: DEBUG
EOF
  ]
  depends_on = [
    null_resource.connect_to_gke,
    google_compute_global_address.cluster-cloud-armor-address,
    module.gke
  ]
}