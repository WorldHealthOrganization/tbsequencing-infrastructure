module "waf" {
  source    = "git::git@bitbucket.org:awsopda/who-seq-treat-tbkb-terraform-modules.git//waf?ref=waf-v1.5"
  lb_arn    = module.alb.load_balancer_arn.lb
  cf_domain = var.cf_domain
}
