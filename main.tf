module "wireguard" {
  source = "git::https://github.com/suquant/tf_wireguard.git?ref=v1.0.0"

  count         = "${var.master_count}"
  connections   = ["${var.master_public_ips}"]
  private_ips   = ["${var.master_private_ips}"]
}

module "etcd" {
  source = "git::https://github.com/suquant/tf_etcd.git?ref=v1.1.0"

  count       = "${var.master_count}"
  connections = ["${var.master_public_ips}"]

  hostnames   = ["${var.master_hostnames}"]
  private_ips = ["${module.wireguard.ips}"]
}

module "docker_master" {
  source = "git::https://github.com/suquant/tf_docker.git?ref=v1.0.0"

  count       = "${var.master_count}"
  # Fix of conccurent apt install running: will run only after wireguard has been installed
  connections = ["${module.wireguard.public_ips}"]

  docker_opts = ["${local.docker_opts}"]
}

module "docker_worker" {
  source = "git::https://github.com/suquant/tf_docker.git?ref=v1.0.0"

  count       = "${var.worker_count}"
  connections = ["${var.worker_public_ips}"]

  docker_opts = ["${local.docker_opts}"]
}

module "kuber_master" {
  source = "git::https://github.com/suquant/tf_kuber_master.git?ref=v1.0.0"

  count           = "${var.master_count}"
  connections     = ["${module.docker_master.public_ips}"]

  private_ips     = ["${var.master_private_ips}"]
  etcd_endpoints  = "${module.etcd.client_endpoints}"
}

module "kuber_worker" {
  source = "git::https://github.com/suquant/tf_kuber_worker.git?ref=v1.0.0"

  count       = "${var.worker_count}"
  connections = ["${module.docker_worker.public_ips}"]

  join_command        = "${module.kuber_master.join_command}"
  kubernetes_version  = "${module.kuber_master.kubernetes_version}"
}

module "kuber_halb" {
  source = "git::https://github.com/suquant/tf_kuber_halb.git?ref=v1.0.1"

  count       = "${var.master_count > 1 ? var.master_count + var.worker_count : 0}"
  connections = ["${concat(module.kuber_master.public_ips, module.kuber_worker.public_ips)}"]

  master_connection = "${module.kuber_master.public_ips[0]}"
  api_endpoints     = ["${module.kuber_master.api_endpoints}"]
}