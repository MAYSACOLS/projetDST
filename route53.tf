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
