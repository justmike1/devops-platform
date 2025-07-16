variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Resource group location"
}

variable "create_resource_group" {
  type     = bool
  default  = true
  nullable = false
}

variable "min_count" {
  type        = number
  description = "node pool min count"
  default     = 1
}

variable "max_count" {
  type        = number
  description = "node pool max count"
  default     = 5
}

variable "os_disk_size_gb" {
  type        = number
  description = "Disk size of nodes in GBs."
  default     = 30 # Minimum value for this parameter is 30 GB
}

variable "create_vnet" {
  type     = bool
  default  = false
  nullable = false
}

variable "create_appgw" {
  type     = bool
  default  = true
  nullable = false
}


variable "create_storage" {
  type     = bool
  default  = false
  nullable = false
}

variable "spot_vm_size" {
  type        = string
  description = "VM size for the spot node pool"
  default     = "Standard_D16ps_v6"
}

variable "worker_vm_size" {
  type        = string
  description = "VM size for the worker node pool"
  default     = "Standard_D8plds_v6"
}

variable "create_postgresql" {
  type     = bool
  default  = false
  nullable = false
}

variable "postgresql_sku_name" {
  type        = string
  description = "SKU name for the PostgreSQL server"
  default     = "B_Standard_B1ms"
}

variable "db_names" {
  type        = list(any)
  description = "postgresql database names"
  default     = []
}

variable "postgresql_storage_mb" {
  type        = number
  description = "Storage size in MB for the PostgreSQL server"
  default     = 32768 # 32 GB - Minimum value for this parameter is 32768 MB
}

variable "sql_username" {
  type        = string
  description = "SQL server admin username"
  default     = "sqladmin"
}

variable "sql_public_access" {
  type        = bool
  description = "Whether to allow public access to the SQL server"
  default     = false
}

variable "default_np_agent_size" {
  type        = string
  description = "Default node pool agent size"
  default     = "Standard_D2s_v3"
}

variable "default_np_min_count" {
  type        = number
  description = "Default node pool min count"
  default     = 1
}

variable "default_np_max_count" {
  type        = number
  description = "Default node pool max count"
  default     = 1
}

variable "enable_spot_node_pool" {
  type        = bool
  description = "Whether to apply spot node pool to the cluster"
  default     = false
}