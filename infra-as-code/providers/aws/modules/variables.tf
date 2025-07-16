variable "cluster_addons" {
  description = "Which cluster addons should we create"
  type        = any
  default = {
    coredns = {
      version           = "latest"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      version           = "latest"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      version           = "latest"
      resolve_conflicts = "OVERWRITE"
    }
  }
}

variable "master_machine_type" {
  type        = string
  description = "cluster's master node pool machine"
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

variable "enable_service_directory" {
  type        = bool
  description = "Whether to create AWS service directory"
  default     = false
}

variable "node_machine_size" {
  type        = number
  description = "Node machine size"
}

variable "num_zones" {
  description = "How many zones should we utilize for the eks nodes"
  type        = number
}

variable "k8s_version" {
  description = "Which version of k8s to install by default"
  type        = string
}

variable "cluster_name" {
  description = "k8s cluster name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "dynamodb_table_name" {
  description = "dynamodb table name"
  type        = string
}

variable "s3_state_bucket_name" {
  description = "s3 state bucket name"
  type        = string
}

variable "name_prefix" {
  type        = string
  description = "Prefix to be used on each infrastructure object Name created in AWS."
}

variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins"
}

variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers"
  default     = ["api-user"]
}
