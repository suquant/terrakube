variable "master_count" {}
variable "master_public_ips" {
  type = "list"
}
variable "master_private_ips" {
  type = "list"
}
variable "master_hostnames" {
  type = "list"
}

variable "worker_count" {}
variable "worker_public_ips" {
  type = "list"
}
variable "worker_private_ips" {
  type = "list"
}
variable "worker_hostnames" {
  type = "list"
}

variable "name" {
  description = "Cluster name"
  default = "default"
}

variable "domain" {
  description = "Cluster domain"
  default = "cluster.local"
}

variable "overlay_cidr" {
  default = "10.244.0.0/16"
}

variable "kubernetes_version" {
  default = "1.10"
}
