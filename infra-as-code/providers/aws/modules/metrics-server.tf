resource "helm_release" "metrics" {
  chart      = "metrics-server"
  namespace  = "kube-system"
  name       = "metrics-server"
  version    = "6.1.2"
  repository = "https://charts.bitnami.com/bitnami"

  values = [<<EOF
extraArgs:
  - --kubelet-insecure-tls=true
  - --kubelet-preferred-address-types=InternalIP
apiService:
  create: true
EOF
  ]
  depends_on = [module.eks]
}

