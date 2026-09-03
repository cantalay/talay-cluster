provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

resource "kubernetes_namespace_v1" "platform" {
  for_each = var.namespaces

  metadata {
    name = each.value
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "talay.io/tier"                = contains(["applications"], each.value) ? "workload" : "platform"
    }
  }
}

resource "kubernetes_priority_class_v1" "platform_critical" {
  metadata {
    name = "talay-platform-critical"
  }

  value          = 1000000
  global_default = false
  description    = "Talay platform components required to operate and recover the cluster."
}

resource "kubernetes_priority_class_v1" "workload_high" {
  metadata {
    name = "talay-workload-high"
  }

  value          = 100000
  global_default = false
  description    = "Business-critical Talay application workloads."
}
