# resource "null_resource" "kube_configuration" {
#   provisioner "local-exec" {
#     command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"

#   }
# }