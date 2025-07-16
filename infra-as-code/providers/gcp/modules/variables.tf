variable "project_id" {
  type        = string
  description = "name of the project in google cloud"
}

variable "domain" {
  type        = string
  description = "domain of the cluster"
}

variable "regional_gke" {
  type        = bool
  description = "whether to make the gke regional or zonal"
}

variable "backend_bucket" {
  type        = string
  description = "name of the gcs backend bucket"
  default     = ""
}

variable "region" {
  type        = string
  description = "cluster's region"
}

variable "spot_gke" {
  type        = bool
  description = "whether to create the gke with spot machines"
}

variable "cluster_name" {
  type        = string
  description = "cluster's name"
  default     = ""
}

variable "environment" {
  type        = string
  description = "cluster's env"
  default     = ""
}

variable "master_machine_type" {
  type        = string
  description = "cluster's master node pool machine"
  default     = "e2-small"
}
variable "master_min_count" {
  type        = number
  description = "cluster's master node pool min count"
  default     = 1
}

variable "master_max_count" {
  type        = number
  description = "cluster's master node pool max count"
  default     = 10
}
variable "spot_machine_type" {
  type        = string
  description = "cluster's spot node pool machine"
  default     = "e2-small"
}
variable "spot_min_count" {
  type        = number
  description = "cluster's spot node pool min count"
  default     = 1
}

variable "spot_max_count" {
  type        = number
  description = "cluster's spot node pool max count"
  default     = 10
}

variable "master_disk_size_gb" {
  type        = number
  description = "cluster's master node pool disk size in gb. ( Default is the minimum required. )"
  default     = 30
}

variable "spot_disk_size_gb" {
  type        = number
  description = "cluster's spot node pool disk size in gb. ( Default is the minimum required. )"
  default     = 30
}
variable "enable_iap" {
  type        = bool
  description = "whether to enable identity aware proxy protection on the loadBalancer"
  default     = false
}

variable "enable_armored_gce_lb" {
  type        = bool
  description = "whether to enable armored gce load balancer with global static ip and security policy"
  default     = false
}

variable "whitelist_ips" {
  type        = list(string)
  description = "list of ips to whitelist for nat"
  default     = []
}

variable "encoded_tls_key_secret_name" {
  type        = string
  description = "secret name of tls key"
  default     = "None"
}

variable "encoded_tls_crt_secret_name" {
  type        = string
  description = "secret name of tls crt"
  default     = "None"
}

variable "enable_traefik" {
  type        = bool
  description = "whether to deploy traefik reverse proxy"
  default     = false
}

variable "bastion_whitelist_ips" {
  type        = list(string)
  description = "A list of CIDR blocks (e.g. ['203.0.113.5/32', '198.51.100.7/32']) that are allowed to SSH to the bastion"
  default     = []
}

variable "enable_private_gke" {
  type        = bool
  description = "whether to deploy private gke cluster"
  default     = false
}

variable "enable_bastion" {
  type        = bool
  description = "whether to deploy bastion instance"
  default     = false
}

variable "enable_spot_pool" {
  type        = bool
  description = "whether to deploy spot node pool"
  default     = false
}
