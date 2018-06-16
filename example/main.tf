variable "token" {}
variable "name" {
  default = "kuber"
}
variable "master_count" {
  default = 3
}
variable "worker_count" {
  default = 3
}

provider "hcloud" {
  token = "${var.token}"
}

module "provider_master" {
  source = "git::https://github.com/suquant/tf_hcloud.git"

  count = "${var.master_count}"
  token = "${var.token}"

  name        = "${format("%s-master", var.name)}"
  server_type = "cx21"
}

module "provider_worker" {
  source = "git::https://github.com/suquant/tf_hcloud.git"

  count = "${var.worker_count}"
  token = "${var.token}"

  name        = "${format("%s-worker", var.name)}"
  ssh_names   = ["${module.provider_master.ssh_names}"]
  ssh_keys    = []
  server_type = "cx11"
}

module "terrakube" {
  source = ".."

  name                = "${var.name}"

  # Masters
  master_count        = "${var.master_count}"
  master_public_ips   = ["${module.provider_master.public_ips}"]
  master_private_ips  = ["${module.provider_master.private_ips}"]
  master_hostnames    = ["${module.provider_master.hostnames}"]

  # Workers
  worker_count        = "${var.worker_count}"
  worker_public_ips   = ["${module.provider_worker.public_ips}"]
  worker_private_ips  = ["${module.provider_worker.private_ips}"]
  worker_hostnames    = ["${module.provider_worker.hostnames}"]
}