# talay-cluster

K3s makinesini kurar ve platformun paylaştığı Kubernetes temel nesnelerini oluşturur.

- `stacks/bootstrap`: SSH üzerinden exact K3s sürümünü kurar/yükseltir, Traefik'in K3s paketini kapatır, Secret encryption-at-rest'i açar, `terraform-states` namespace'ini hazırlar ve kubeconfig'i yerel güvenli dosyaya alır.
- `stacks/base`: Ortak namespace'ler ile platform/workload priority class'larını oluşturur.

Bootstrap state'i zorunlu olarak yereldir; cluster'ı oluşturan state cluster'ın içinde tutulamaz. Base ve diğer bütün platform state'leri, bootstrap'ın oluşturduğu `terraform-states` namespace'indeki Kubernetes Secret'larında kilitlenerek tutulur. Böylece Kubernetes API erişilemezken bootstrap state'i yine yönetilebilir.

Kubernetes backend state'leri K3s encryption-at-rest ile korunur; buna rağmen cluster kaybına karşı düzenli olarak şifreli cluster-dışı yedek alınmalıdır. Secret veya private key'i tfvars'a koymayın. `ssh_private_key_path` yalnızca dosya yoludur.

Yerel şifreli state yedeği ve kontrollü restore:

```bash
./scripts/backup-kubernetes-state.sh /secure/path/talay-state-$(date +%F).json.gpg
./scripts/restore-kubernetes-state.sh /secure/path/talay-state-2026-09-04.json.gpg
STATE_RESTORE_APPLY=true ./scripts/restore-kubernetes-state.sh /secure/path/talay-state-2026-09-04.json.gpg
```

Script'ler varsayılan olarak yedek parolasını OS keyring'deki `service=talay-vault-migration`, `backup=legacy-2026-09-04` kaydından okur. Restore varsayılan olarak yalnız dry-run yapar.
