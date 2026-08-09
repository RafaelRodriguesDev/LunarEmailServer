#!/usr/bin/env bash
set -Eeuo pipefail

POSTE_DATA_PATH="${POSTE_DATA_PATH:-/opt/LunarWaveEmail/poste/data}"
POSTE_BACKUP_PATH="${POSTE_BACKUP_PATH:-/opt/LunarWaveEmail/poste/backups}"
TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"
BACKUP_FILE="${POSTE_BACKUP_PATH}/poste_${TIMESTAMP}.tar.gz"

if [[ ! -d "${POSTE_DATA_PATH}" ]]; then
  echo "Erro: diretorio de dados nao encontrado: ${POSTE_DATA_PATH}" >&2
  exit 1
fi

mkdir -p "${POSTE_BACKUP_PATH}"

tar -C "$(dirname "${POSTE_DATA_PATH}")" \
  -czf "${BACKUP_FILE}" \
  "$(basename "${POSTE_DATA_PATH}")"

echo "Backup criado em: ${BACKUP_FILE}"
