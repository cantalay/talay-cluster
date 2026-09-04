locals {
  ssh_key_path = pathexpand(var.ssh_private_key_path)
  sudo         = var.ssh_user == "root" ? "" : "sudo "
}

resource "terraform_data" "k3s_server" {
  triggers_replace = [
    var.server_ip,
    var.k3s_version,
    var.cluster_cidr,
    var.service_cidr,
  ]

  connection {
    type        = "ssh"
    host        = var.server_ip
    port        = var.ssh_port
    user        = var.ssh_user
    private_key = file(local.ssh_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "if ! command -v k3s >/dev/null 2>&1 || ! k3s --version | head -n1 | grep -F '${var.k3s_version}' >/dev/null; then curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='${var.k3s_version}' sh -s - server --disable=traefik --secrets-encryption --write-kubeconfig-mode=600 --tls-san='${var.server_ip}' --cluster-cidr='${var.cluster_cidr}' --service-cidr='${var.service_cidr}'; fi",
      "${local.sudo}systemctl enable --now k3s",
      "${local.sudo}k3s kubectl wait --for=condition=Ready node --all --timeout=300s",
      "${local.sudo}k3s kubectl create namespace terraform-states --dry-run=client -o yaml | ${local.sudo}k3s kubectl apply -f -",
      "${local.sudo}k3s kubectl label namespace terraform-states app.kubernetes.io/managed-by=terraform-bootstrap talay.io/tier=platform --overwrite",
    ]
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -eu
      install -d -m 0700 "$(dirname '${var.kubeconfig_output_path}')"
      ssh -p '${var.ssh_port}' -i '${local.ssh_key_path}' -o StrictHostKeyChecking=accept-new '${var.ssh_user}@${var.server_ip}' '${local.sudo}cat /etc/rancher/k3s/k3s.yaml' > '${var.kubeconfig_output_path}'
      chmod 0600 '${var.kubeconfig_output_path}'
      sed -i 's#https://127.0.0.1:6443#https://${var.server_ip}:6443#' '${var.kubeconfig_output_path}'
    EOT
  }
}
