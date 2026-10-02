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

# GitHub signs the OIDC subject with immutable ids (owner@id/repo@id), so a
# rename doesn't silently grant access to whoever takes the old name. Read it
# from the API: gh api repos/OWNER/REPO/actions/oidc/customization/sub
variable "github_subject_prefix" {
  description = "sub_claim_prefix of the repository allowed to deploy."
  type        = string
  default     = "repo:joaolaureano@42150235/portfolio@1400982272"
}

variable "create_github_oidc_provider" {
  description = "An AWS account holds a single GitHub OIDC provider. Set to false if one already exists."
  type        = bool
  default     = true
}
