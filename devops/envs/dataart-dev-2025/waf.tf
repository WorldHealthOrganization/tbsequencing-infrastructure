module "waf" {
  count     = !var.low_cost_implementation && var.waf ? 1 : 0
  source    = "git::https://github.com/finddx/seq-treat-tbkb-terraform-modules.git//waf?ref=waf-v1.6"
  lb_arn    = module.alb.load_balancer_arn.lb
  cf_domain = var.cf_domain
}
