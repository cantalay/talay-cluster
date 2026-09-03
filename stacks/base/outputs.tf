output "namespaces" {
  value = sort(tolist(var.namespaces))
}

output "priority_classes" {
  value = [
    kubernetes_priority_class_v1.platform_critical.metadata[0].name,
    kubernetes_priority_class_v1.workload_high.metadata[0].name,
  ]
}
