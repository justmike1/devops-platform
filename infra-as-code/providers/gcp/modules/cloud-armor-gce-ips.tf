resource "google_compute_global_address" "gce_static_ip" {
  count   = var.enable_armored_gce_lb ? 1 : 0
  name    = "${local.cluster_name}-global-static-ip"
  project = var.project_id
}

resource "google_compute_security_policy" "gce_lb_policy" {
  count = var.enable_armored_gce_lb ? 1 : 0
  name  = "${google_compute_global_address.gce_static_ip[count.index].name}-policy"

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Deny access to all IPs"
  }

  dynamic "rule" {
    for_each = { for idx, ip_range_chunk in chunklist(var.whitelist_ips, 10) : idx => ip_range_chunk }
    content {
      action   = "allow"
      priority = 1000 + rule.key
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
      description = "Allow access to whitelisted IPs part ${rule.key}"
    }
  }
  depends_on = [google_compute_global_address.gce_static_ip]
}