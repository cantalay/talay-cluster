#!/usr/bin/env bash
set -euo pipefail
umask 077

input_path=${1:?Usage: restore-kubernetes-state.sh INPUT.gpg}
namespace=${TF_STATE_NAMESPACE:-terraform-states}
keyring_service=${STATE_BACKUP_KEYRING_SERVICE:-talay-vault-migration}
keyring_backup=${STATE_BACKUP_KEYRING_BACKUP:-legacy-2026-09-04}
restore_apply=${STATE_RESTORE_APPLY:-false}
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

[[ -r "$input_path" ]] || {
  printf 'Backup is not readable: %s\n' "$input_path" >&2
  exit 1
}

case "$restore_apply" in
  true | false) ;;
  *)
    printf 'STATE_RESTORE_APPLY must be true or false.\n' >&2
    exit 1
    ;;
esac

backup_passphrase=$(secret-tool lookup service "$keyring_service" backup "$keyring_backup")
[[ -n "$backup_passphrase" ]] || {
  printf 'Backup passphrase was not found in the OS keyring.\n' >&2
  exit 1
}

state_json=$(
  gpg --batch --quiet --decrypt --pinentry-mode loopback --passphrase-fd 3 \
    "$input_path" 3<<<"$backup_passphrase" \
    | jq -ec --arg namespace "$namespace" '
        .items |= map(
          select(.metadata.name | startswith("tfstate-"))
          | .metadata.namespace = $namespace
        )
        | if (.items | length) > 0 then . else error("no Terraform state Secrets found") end
      '
)
unset backup_passphrase

printf 'Backup contains %s Terraform state Secret(s).\n' "$(jq -r '.items | length' <<<"$state_json")"
if [[ "$restore_apply" != true ]]; then
  printf 'Dry-run only. Set STATE_RESTORE_APPLY=true to apply them.\n'
  exit 0
fi

kubectl "${kubectl_args[@]}" create namespace "$namespace" --dry-run=client -o yaml \
  | kubectl "${kubectl_args[@]}" apply -f - >/dev/null
kubectl "${kubectl_args[@]}" apply -f - <<<"$state_json" >/dev/null
printf 'Terraform state Secrets restored to namespace %s.\n' "$namespace"
