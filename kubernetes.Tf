provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}
# resource "kubernetes_namespace" "wordpress" {
#   metadata {
#     name = "wordpress"
#   }
# }
# #Creation de la configuration config_map
# resource "kubernetes_config_map" "wordpress_configmap" {
#   metadata {
#     name = "wordpress-config"
#   }
#   data = {
#     WORDPRESS_DB_HOST = "mariadb"
#     WORDPRESS_DB_NAME = "wordpress"
#     WORDPRESS_DB_USER = "admin"
#   }
# }

# resource "kubernetes_secret" "wordpress_secret" {
#   metadata {
#     name = "wordpress-secret"
#     namespace = kubernetes_namespace.wordpress.metadata[0].name
#   }
#   data = {
#     WORDPRESS_DB_PASSWORD = base64encode(var.db_password)
#     MYSQL_ROOT_PASSWORD   = base64encode(var.db_password)
#   }
# }

# # Déploiement de WordPress
# resource "kubernetes_deployment" "wordpress" {
#   metadata {
#     name      = "wordpress"
#     namespace = kubernetes_namespace.wordpress.metadata[0].name
#   }
#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         app = "wordpress"
      
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "wordpress"
          
#         }
#          annotations = {
#           "eks.amazonaws.com/fargate-profile" = "fargate-profile"  # Remplacez par le nom de votre profil Fargate
#         }
#       }
#       spec {
#         container {
#           name  = "wordpress"
#           image = "wordpress:latest"
#           env {
#             name  = "WORDPRESS_DB_HOST"
#             value = "${output.rds_endpoint}:3306"
#           }
#           env {
#             name  = "WORDPRESS_DB_NAME"
#             value = "wordpressdb"
#           }
#           env {
#             name  = "WORDPRESS_DB_USER"
#             value = "admin"
#           }
#           env {
#             name = "WORDPRESS_DB_PASSWORD"
#             value_from {
#               secret_key_ref {
#                 name = "wordpress-secret"
#                 key  = "WORDPRESS_DB_PASSWORD"
#               }
#             }
#           }
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "wordpress" {
#   metadata {
#     name      = "wordpress"
#     namespace = kubernetes_namespace.wordpress.metadata[0].name
#   }
#   spec {
#     selector = {
#       app = "wordpress"
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }
#     type = "ClusterIP"
#   }
# }

locals {
  manifests = fileset("${path.module}/deployment_files", "*.yaml")  # Répertoire de vos manifestes YAML
}

resource "kubernetes_manifest" "apply_manifests" {
  for_each = toset(local.manifests)

  manifest = yamldecode(file("${path.module}/deployment_files/${each.value}"))
}
resource "kubernetes_ingress" "wordpress" {
  metadata {
    name      = "wordpress-ingress"
    namespace = kubernetes_namespace.wordpress.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                      = "alb"
      "alb.ingress.kubernetes.io/load-balancer-arn"      = aws_lb.wordpress.arn
      "alb.ingress.kubernetes.io/target-group-arn"       = aws_lb_target_group.wordpress.arn
      "alb.ingress.kubernetes.io/listen-ports"           = jsonencode([{
        HTTP = 80
      }])
      "alb.ingress.kubernetes.io/scheme"                 = "internet-facing"
      "alb.ingress.kubernetes.io/security-groups"        = aws_security_group.wordpress.id
      "alb.ingress.kubernetes.io/subnets"                = join(",", module.vpc.public_subnets)
    }
  }
  spec {
    rule {
      host = "projetweb.maysadevops.dns-dynamic.net"
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.wordpress_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Type A on lie le DNS à l'adresse IP du load Balancer
resource "aws_route53_record" "projetweb" {
  zone_id = aws_lb.wordpress.zone_id  # Remplacez par votre ID de zone
  name    = "projetweb.maysadevops.dns-dynamic.net"
  type    = "A"
  
  alias {
    name                   = aws_lb.wordpress.dns_name
    zone_id                = aws_lb.wordpress.zone_id # Remplacez par l'ID de zone de l'ELB
    evaluate_target_health = true
  }
}
#pour HTTPS
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
      zone_id  = aws_lb.wordpress.zone_id # Remplacez par l'ID de zone de l'ELB  # Remplacez par votre ID de zone
    }
  }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}
resource "aws_acm_certificate" "cert" {
  domain_name       = "projetweb.maysadevops.dns-dynamic.net"
  validation_method = "DNS"

  tags = {
    Name = "projetweb-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
