locals {
  cluster_name = var.environment != "" ? "${var.environment}-gke" : var.cluster_name
  public_subnet = one([
    for subnet in module.vpc.subnets : subnet.self_link
    if subnet.name == "public-subnet"
  ])
}