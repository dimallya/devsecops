variable "role_id" {
  type        = string
  description = "Role id for approle"
}

variable "secret_id" {
  type        = string
  description = "Secret id for approle"
}

variable "kube_host" {
  type        = string
  description = "kubernetes host"
}

variable "namespace" {
  type        = string
  description = "kubernetes namespace"
}