module "k3s" {
  source = "../../modules/k3s"

  server_ip              = var.server_ip
  ssh_user               = var.ssh_user
  ssh_port               = var.ssh_port
  ssh_private_key_path   = var.ssh_private_key_path
  ssh_host_key           = var.ssh_host_key
  k3s_version            = var.k3s_version
  cluster_cidr           = var.cluster_cidr
  service_cidr           = var.service_cidr
  kubeconfig_output_path = var.kubeconfig_output_path
}

moved {
  from = terraform_data.k3s_server
  to   = module.k3s.terraform_data.k3s_server
}
