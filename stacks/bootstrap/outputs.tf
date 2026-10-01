output "k3s_version" {
  value = module.k3s.k3s_version
}

output "api_server" {
  value = module.k3s.api_server
}

output "kubeconfig_path" {
  value = module.k3s.kubeconfig_path
}
