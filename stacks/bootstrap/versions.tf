terraform {
  required_version = "~> 1.16.0"

  # This state must remain available while the cluster itself is unavailable.
  backend "local" {}
}
