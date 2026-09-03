variable "kubeconfig_path" {
  type    = string
  default = "../bootstrap/kubeconfig.yaml"
}

variable "namespaces" {
  type = set(string)
  default = [
    "applications",
    "cert-manager",
    "data",
    "external-secrets",
    "gitops",
    "identity",
    "ingress-system",
    "monitoring",
    "platform-system",
    "vault",
  ]
}
