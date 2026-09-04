#!/usr/bin/env bash
set -euo pipefail
umask 077

output_path=${1:?Usage: backup-kubernetes-state.sh OUTPUT.gpg}
namespace=${TF_STATE_NAMESPACE:-terraform-states}
keyring_service=${STATE_BACKUP_KEYRING_SERVICE:-talay-vault-migration}
keyring_backup=${STATE_BACKUP_KEYRING_BACKUP:-legacy-2026-09-04}
kubectl_args=()

if [[ -n "${KUBECONFIG:-}" ]]; then
  kubectl_args+=(--kubeconfig "$KUBECONFIG")
fi

for command_name in kubectl jq gpg secret-tool; do
  command -v "$command_name" >/dev/null || {
    printf 'Required command is missing: %s\n' "$command_name" >&2
    exit 1
  }
done

[[ ! -e "$output_path" ]] || {
  printf 'Refusing to overwrite existing backup: %s\n' "$output_path" >&2
  exit 1
}

backup_passphrase=$(secret-tool lookup service "$keyring_service" backup "$keyring_backup")
[[ -n "$backup_passphrase" ]] || {
  printf 'Backup passphrase was not found in the OS keyring.\n' >&2
  exit 1
}

kubectl "${kubectl_args[@]}" -n "$namespace" get secrets -o json \
  | jq -e '{
      apiVersion: "v1",
      kind: "List",
      items: [
        .items[]
        | select(.metadata.name | startswith("tfstate-"))
        | {
            apiVersion,
            kind,
            metadata: {
              name: .metadata.name,
              namespace: .metadata.namespace,
              labels: .metadata.labels,
              annotations: .metadata.annotations
            },
            type,
            data
          }
      ]
    }
    | if (.items | length) > 0 then . else error("no Terraform state Secrets found") end' \
  | gpg --batch --yes --symmetric --cipher-algo AES256 --pinentry-mode loopback \
      --passphrase-fd 3 --output "$output_path" 3<<<"$backup_passphrase"

chmod 0600 "$output_path"
item_count=$(
  gpg --batch --quiet --decrypt --pinentry-mode loopback --passphrase-fd 3 \
    "$output_path" 3<<<"$backup_passphrase" \
    | jq -er '.items | length'
)
unset backup_passphrase

printf 'Encrypted and verified %s Terraform state Secret(s): %s\n' "$item_count" "$output_path"
sha256sum "$output_path"
