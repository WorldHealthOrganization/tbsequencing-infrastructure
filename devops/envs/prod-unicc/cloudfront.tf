module "cloudfront" {
  source                    = "git::git@bitbucket.org:awsopda/who-seq-treat-tbkb-terraform-modules.git//cloudfront?ref=cf-v1.7"
  static_bucket_name        = "${local.prefix}-static-files"
  logs_bucket_name          = "${local.prefix}-cloudfront-logs"
  django_static_bucket_name = "${local.prefix}-django-static-files"
  https_certificate_arn     = data.aws_acm_certificate.tbsequencing.arn
  dns_name                  = var.cf_domain
  elb_dns_name              = module.alb.load_balancer_dns_name["lb"]
  frontend_port             = 80
  frontend_ssl_port         = 443
  waf_web_acl_id            = module.waf.web_acl_arn
  restrictions              = var.cf_restrictions
  project_name              = var.project_name
  environment               = var.environment
}
