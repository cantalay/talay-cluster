module "platform_base" {
  source = "../../modules/platform-base"

  namespaces = var.namespaces
}

moved {
  from = kubernetes_namespace_v1.platform
  to   = module.platform_base.kubernetes_namespace_v1.platform
}

moved {
  from = kubernetes_priority_class_v1.platform_critical
  to   = module.platform_base.kubernetes_priority_class_v1.platform_critical
}

moved {
  from = kubernetes_priority_class_v1.workload_high
  to   = module.platform_base.kubernetes_priority_class_v1.workload_high
}
