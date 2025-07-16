data "google_secret_manager_secret_version" "client_id" {
  count   = var.enable_iap ? 1 : 0
  secret  = "OAUTH2-SSO-CLIENT-ID"
  project = var.project_id
}
data "google_secret_manager_secret_version" "client_secret" {
  count   = var.enable_iap ? 1 : 0
  secret  = "OAUTH2-SSO-CLIENT-SECRET"
  project = var.project_id
}

resource "google_compute_security_policy" "cluster-sec-policy" {
  count   = var.enable_traefik ? 1 : 0
  project = var.project_id
  name    = "${local.cluster_name}-waf-policy"
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}

resource "kubernetes_secret" "lb_iap_sso_credentials" {
  count = var.enable_iap ? 1 : 0
  metadata {
    name      = "${local.cluster_name}-lb-iap-sso"
    namespace = kubernetes_namespace.ingress-ns-traefik[count.index].metadata.0.name
  }

  data = {
    "client_id"     = data.google_secret_manager_secret_version.client_id[count.index].secret_data
    "client_secret" = data.google_secret_manager_secret_version.client_secret[count.index].secret_data
  }

  type = "Opaque"
  depends_on = [
    helm_release.traefik-ingress-controller
  ]
}

resource "google_compute_global_address" "cluster-cloud-armor-address" {
  count   = var.enable_traefik ? 1 : 0
  name    = "${local.cluster_name}-cloud-armor-address"
  project = var.project_id
}

resource "kubernetes_manifest" "cloud-backend-config" {
  count = var.enable_traefik ? 1 : 0

  manifest = {
    apiVersion = "cloud.google.com/v1"
    kind       = "BackendConfig"
    metadata = {
      name      = "backendconfig-${google_compute_security_policy.cluster-sec-policy[count.index].name}"
      namespace = kubernetes_namespace.ingress-ns-traefik[count.index].metadata.0.name
    }
    spec = {
      iap = {
        enabled = var.enable_iap
        oauthclientCredentials = {
          secretName = "${local.cluster_name}-lb-iap-sso"
        }
      }
      timeoutSec = 86400
      connectionDraining = {
        drainingTimeoutSec = 1800
      }
      securityPolicy = {
        name = google_compute_security_policy.cluster-sec-policy[count.index].name
      }
      healthCheck = {
        checkIntervalSec   = 10
        timeoutSec         = 5
        healthyThreshold   = 3
        unhealthyThreshold = 7
        type               = "HTTP"
        requestPath        = "/ping"
        port               = 8000
      }
    }
  }

  depends_on = [
    helm_release.traefik-ingress-controller,
    google_compute_global_address.cluster-cloud-armor-address,
    google_compute_security_policy.cluster-sec-policy
  ]
}