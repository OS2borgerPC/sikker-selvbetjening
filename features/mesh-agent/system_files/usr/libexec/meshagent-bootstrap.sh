#!/usr/bin/env bash
set -euo pipefail

AGENT_DIR="/opt/meshagent"
AGENT_BIN="${AGENT_DIR}/meshagent"
AGENT_MSH="${AGENT_DIR}/meshagent.msh"
AGENT_GROUP_MARKER="${AGENT_DIR}/.groupid"
LOG_DIR="/var/log/meshagent"
LOG_FILE="${LOG_DIR}/meshagent.log"

MESH_AGENT_URL="${MESH_AGENT_URL:-}"
MESH_AGENT_GROUPID="${MESH_AGENT_GROUPID:-}"
MESH_AGENT_ID="${MESH_AGENT_ID:-6}"

if [[ -z "${MESH_AGENT_URL}" ]] || [[ -z "${MESH_AGENT_GROUPID}" ]]; then
  echo "meshagent-bootstrap: MESH_AGENT_URL and MESH_AGENT_GROUPID must be set" >&2
  exit 1
fi

while [[ "${MESH_AGENT_URL}" == */ ]]; do
  MESH_AGENT_URL="${MESH_AGENT_URL%/}"
done

mkdir -p "${AGENT_DIR}" "${LOG_DIR}"
touch "${LOG_FILE}"
chmod 0644 "${LOG_FILE}" || true

if [[ ! -x "${AGENT_BIN}" ]]; then
  curl -fsSL "${MESH_AGENT_URL}/meshagents?id=${MESH_AGENT_ID}" -o "${AGENT_BIN}"
  chmod +x "${AGENT_BIN}"
fi

if command -v restorecon >/dev/null 2>&1; then
  restorecon -RF "${AGENT_DIR}" "${LOG_DIR}" || true
fi
if command -v chcon >/dev/null 2>&1; then
  chcon --reference /usr/bin/bash "${AGENT_BIN}" || true
fi

if [[ ! -f "${AGENT_GROUP_MARKER}" ]] || [[ "$(cat "${AGENT_GROUP_MARKER}")" != "${MESH_AGENT_GROUPID}" ]]; then
  curl -fsSL "${MESH_AGENT_URL}/meshsettings?id=${MESH_AGENT_GROUPID}" -o "${AGENT_MSH}"
  printf '%s' "${MESH_AGENT_GROUPID}" > "${AGENT_GROUP_MARKER}"
elif [[ ! -s "${AGENT_MSH}" ]]; then
  curl -fsSL "${MESH_AGENT_URL}/meshsettings?id=${MESH_AGENT_GROUPID}" -o "${AGENT_MSH}"
fi