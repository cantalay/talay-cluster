terraform {
  required_version = "~> 1.16.0"

  # State, cluster içindeki terraform-states namespace'inde tutulur. Kaynak yalnız SSH ile k3s kurulumunu
  # (idempotent install script) temsil eder; API erişilemezse README'deki acil durum adımlarıyla boş lokal
  # state'le yeniden çalıştırılabilir.
  backend "kubernetes" {}
}
