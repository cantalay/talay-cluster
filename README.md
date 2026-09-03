# talay-cluster

K3s makinesini kurar ve platformun paylaştığı Kubernetes temel nesnelerini oluşturur.

- `stacks/bootstrap`: SSH üzerinden exact K3s sürümünü kurar/yükseltir, Traefik'in K3s paketini kapatır ve kubeconfig'i yerel güvenli dosyaya alır.
- `stacks/base`: Ortak namespace'ler ile platform/workload priority class'larını oluşturur.

İki stack ayrı state kullanır; böylece Kubernetes API erişilemezken sunucu bootstrap state'i yönetilebilir. Secret veya private key'i tfvars/state'e koymayın. `ssh_private_key_path` yalnızca dosya yoludur.
