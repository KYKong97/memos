variable "project_id" {
  description = "The Google Cloud project ID to deploy into."
  type        = string
}

variable "region" {
  description = "The Google Cloud region for regional resources."
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "The Google Cloud zone for the VM instance."
  type        = string
  default     = "asia-southeast1-a"
}

variable "name" {
  description = "Base name used for the VM and related resources."
  type        = string
  default     = "memos"
}

variable "machine_type" {
  description = "Compute Engine machine type."
  type        = string
  default     = "e2-micro"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 20
}

variable "repo_url" {
  description = "Git repository URL to clone during provisioning."
  type        = string
  default     = "https://github.com/usememos/memos.git"
}

variable "repo_ref" {
  description = "Git ref to deploy, such as a branch, tag, or commit SHA."
  type        = string
  default     = "main"
}

variable "domain_name" {
  description = "Optional public domain name for the instance. Leave empty to use the VM public IP."
  type        = string
  default     = ""
}

variable "allow_ssh_cidrs" {
  description = "CIDR ranges allowed to SSH to the VM."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional network tags to add to the instance."
  type        = list(string)
  default     = []
}
