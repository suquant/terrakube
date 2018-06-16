# Kubernetes High Availability Service

## Key features

* High Availability mode if master count >1 
* HA Load Balancer on each worker and master nodes if HA is active
* Dynamic add/remove master or worker nodes
* Preconfigured container network with security option (flannel + wireguard vpn)

## Interfaces

### Input variables

* master_count
* master_public_ips
* master_private_ips
* master_hostnames
* worker_count
* worker_public_ips
* worker_private_ips
* worker_hostnames
* name - cluster name (default: default)
* domain - cluster domain (default: cluster.local)
* overlay_cidr - overlay network cidr (default: 10.244.0.0/16)
* kubernetes_version - (default: 1.10)

### Output variables

* kubeconfig - amdin kubeconfig 
* api_endpoints - master api endpoints
* master_count
* master_public_ips
* worker_count
* worker_public_ips


## Example

```
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
  source = "git::https://github.com/suquant/terrakube.git"

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
```