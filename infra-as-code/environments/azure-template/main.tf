module "kubernetes-cluster" {

  source = "../../providers/azure/modules"

  create_resource_group = true
  create_vnet           = true
  resource_group_name   = "misc"
  location              = "centralindia"
  min_count             = 1
  max_count             = 2
  spot_vm_size          = "Standard_D16s_v5"
  os_disk_size_gb       = 70
  enable_spot_node_pool = true
}
