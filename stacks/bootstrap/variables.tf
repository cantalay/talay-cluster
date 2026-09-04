variable "server_ip" {
  description = "K3s sunucusunun IPv4 veya DNS adresi."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+$", var.server_ip))
    error_message = "server_ip yalnızca geçerli bir IPv4/DNS adı içermelidir."
  }
}

variable "ssh_user" {
  description = "Sunucuya bağlanacak ve passwordless sudo kullanacak kullanıcı."
  type        = string
  default     = "root"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]*$", var.ssh_user))
    error_message = "ssh_user geçerli bir Linux kullanıcı adı olmalıdır."
  }
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "ssh_private_key_path" {
  description = "Private key'in yerel yolu; key içeriği Terraform state'e yazılmaz."
  type        = string
}

variable "ssh_host_key" {
  description = "Önceden doğrulanmış OpenSSH sunucu public key'i; fingerprint doğrulamasını zorunlu kılar."
  type        = string

  validation {
    condition     = can(regex("^(ssh-ed25519|ecdsa-sha2-nistp(256|384|521)|ssh-rsa) [A-Za-z0-9+/=]+$", trimspace(var.ssh_host_key)))
    error_message = "ssh_host_key, örneğin 'ssh-ed25519 AAAA...' biçiminde doğrulanmış bir public host key olmalıdır."
  }
}

variable "k3s_version" {
  type    = string
  default = "v1.36.4+k3s1"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+\\+k3s[0-9]+$", var.k3s_version))
    error_message = "k3s_version v1.36.4+k3s1 biçiminde olmalıdır."
  }
}

variable "cluster_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "10.43.0.0/16"
}

variable "kubeconfig_output_path" {
  type    = string
  default = "./kubeconfig.yaml"
}
