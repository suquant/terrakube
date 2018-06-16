output "kubeconfig" {
  value = "${module.kuber_master.kubeconfig}"
}

output "api_endpoints" {
  value = ["${module.kuber_master.api_endpoints}"]
}

output "master_count" {
  value = "${var.master_count}"
}

output "master_public_ips" {
  value = ["${module.kuber_master.public_ips}"]
}

output "worker_count" {
  value = "${var.worker_count}"
}

output "worker_public_ips" {
  value = ["${module.kuber_worker.public_ips}"]
}