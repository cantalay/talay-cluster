# talay-cluster

K3s makinesini kurar ve platformun paylaştığı Kubernetes temel nesnelerini oluşturur.

- `stacks/bootstrap` -> `modules/k3s`: SSH üzerinden exact K3s sürümünü kurar/yükseltir, Traefik'in K3s paketini kapatır, Secret encryption-at-rest'i açar, `terraform-states` namespace'ini hazırlar ve kubeconfig'i yerel güvenli dosyaya (`kubeconfig.yaml`, git'e girmez) alır.
- `stacks/base` -> `modules/platform-base`: Ortak namespace'ler ile platform/workload priority class'larını oluşturur.

Bütün state'ler, bootstrap dahil, `terraform-states` namespace'indeki Kubernetes Secret'larında kilitlenerek tutulur
(bootstrap: `tfstate-default-talay-cluster-bootstrap`). Yerelde state dosyası tutulmaz.

Bootstrap state'i yalnız bir `terraform_data` kaynağıdır: "bu sürüm/ayarlarla install script'i SSH üzerinden çalıştı".
Kurulum script'i idempotenttir; bu yüzden state'in cluster içinde olması güvenlidir.

### Acil durum: Kubernetes API erişilemezken bootstrap

K3s'i SSH ile onarmak/yeniden kurmak için backend'i geçici olarak boş yerel state'e çevirin:

```bash
cd stacks/bootstrap
cat > backend_override.tf <<'HCL'
terraform {
  backend "local" {}
}
HCL
terraform init -reconfigure
terraform apply            # install script'ini SSH ile yeniden çalıştırır, kubeconfig'i yeniden alır
rm backend_override.tf terraform.tfstate*
terraform init -reconfigure -backend-config=backend.hcl   # API geri geldiğinde cluster içindeki state'e dön
terraform apply            # trigger'ları cluster state'ine yazar
```

Kubernetes backend state'leri K3s encryption-at-rest ile korunur; buna rağmen cluster kaybına karşı düzenli olarak şifreli cluster-dışı yedek alınmalıdır. Secret veya private key'i tfvars'a koymayın. `ssh_private_key_path` yalnızca dosya yoludur. `ssh_host_key` ise bağlantıdan önce bağımsız olarak doğrulanmış OpenSSH public host key'idir; aynı host ayrıca yerel `known_hosts` içinde bulunmalıdır.

Yerel şifreli state yedeği ve kontrollü restore:

```bash
./scripts/backup-kubernetes-state.sh /secure/path/talay-state-$(date +%F).json.gpg
./scripts/restore-kubernetes-state.sh /secure/path/talay-state-2026-09-04.json.gpg
STATE_RESTORE_APPLY=true ./scripts/restore-kubernetes-state.sh /secure/path/talay-state-2026-09-04.json.gpg
```

Script'ler varsayılan olarak yedek parolasını OS keyring'deki `service=talay-vault-migration`, `backup=legacy-2026-09-04` kaydından okur. Restore varsayılan olarak yalnız dry-run yapar.
