resource "helm_release" "aws-ebs-csi-driver" {
  name             = "aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  version          = "2.19.0"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  namespace        = "ebs-driver"
  create_namespace = true
  depends_on = [
    module.eks
  ]
}
