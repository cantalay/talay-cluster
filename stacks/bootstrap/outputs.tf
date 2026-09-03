output "k3s_version" {
  value = var.k3s_version
}

output "api_server" {
  value = "https://${var.server_ip}:6443"
}

output "kubeconfig_path" {
  value = abspath(var.kubeconfig_output_path)
}
