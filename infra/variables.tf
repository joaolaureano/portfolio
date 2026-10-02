variable "project_name" {
  description = "Prefix for every resource name."
  type        = string
  default     = "portfolio"
}

variable "domain_name" {
  description = "Apex domain the site is served from. www redirects to it."
  type        = string
  default     = "joaolaureano.dev"
}

variable "github_repository" {
  description = "owner/name of the repository allowed to deploy through GitHub Actions."
  type        = string
  default     = "joaolaureano/portfolio"
}

variable "create_github_oidc_provider" {
  description = "An AWS account holds a single GitHub OIDC provider. Set to false if one already exists."
  type        = bool
  default     = true
}
