# global
variable "project_name" {
  type        = string
  default     = "fdx"
  description = "Project name"
}

variable "module_name" {
  type        = string
  default     = "main"
  description = "Infrastructure module name"
}

variable "environment" {
  type = string
}

# ecr 
variable "ecr_image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "cf_domain" {
  type = string
}

variable "no_reply_email" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cf_restrictions" {
  type = object({
    type      = string,
    locations = list(string)
    }
  )
  default = {
    type      = "none"
    locations = []
  }
}

variable "github_org_name" {
  type = string
}
