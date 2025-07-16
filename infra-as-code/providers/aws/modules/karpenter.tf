module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.21.1"

  role_name                          = "karpenter-controller-${var.cluster_name}"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_id = module.eks.cluster_id
  karpenter_controller_ssm_parameter_arns = [
    "arn:${local.partition}:ssm:*:*:parameter/aws/service/*"
  ]
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["master"].iam_role_arn
  ]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.eks.eks_managed_node_groups["master"].iam_role_name
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter/"
  chart      = "karpenter"
  version    = "v0.27.5"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_irsa.iam_role_arn
  }

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.eks.cluster_id
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  depends_on = [module.eks]
}

# Workaround - https://github.com/hashicorp/terraform-provider-kubernetes/issues/1380#issuecomment-967022975
resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "default"
    }
    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot"]
        }
      ]
      limits = {
        resources = {
          cpu = 1000
        }
      }
      provider = {
        subnetSelector = {
          "karpenter.sh/discovery" = var.cluster_name
        }
        securityGroupSelector = {
          "karpenter.sh/discovery" = var.cluster_name
        }
        tags = {
          "karpenter.sh/discovery" = var.cluster_name
        }
      }
      ttlSecondsAfterEmpty = 30
    }
  }

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_example_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name = "inflate"
    }
    spec = {
      replicas = 0
      selector = {
        matchLabels = {
          app = "inflate"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "inflate"
          }
        }
        spec = {
          terminationGracePeriodSeconds = 0
          containers = [
            {
              name  = "inflate"
              image = "public.ecr.aws/eks-distro/kubernetes/pause:3.2"
              resources = {
                requests = {
                  cpu = 1
                }
              }
            }
          ]
        }
      }
    }
  }

  depends_on = [
    helm_release.karpenter
  ]
}