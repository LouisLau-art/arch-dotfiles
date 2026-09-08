#!/usr/bin/env bash
# fcitx5 + Rime 一键恢复脚本（幂等，可重复执行）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${HOME}/.config/fcitx5-backup"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

FCITX5_CONFIG_DIR="${HOME}/.config/fcitx5"
RIME_USER_DIR="${HOME}/.local/share/fcitx5/rime"

mkdir -p "${FCITX5_CONFIG_DIR}" "${RIME_USER_DIR}" "${BACKUP_DIR}"

backup_if_exists() {
  local src="$1"
  local rel="$2"
  if [ -e "${src}" ]; then
    mkdir -p "${BACKUP_DIR}/$(dirname "${rel}")"
    cp -a "${src}" "${BACKUP_DIR}/${rel}"
    echo "已备份: ${src} -> ${BACKUP_DIR}/${rel}"
  fi
}

echo "==> 备份旧配置到 ${BACKUP_DIR}"

backup_if_exists "${FCITX5_CONFIG_DIR}/config" "fcitx5/config"
backup_if_exists "${FCITX5_CONFIG_DIR}/profile" "fcitx5/profile"
if [ -d "${FCITX5_CONFIG_DIR}/conf" ]; then
  mkdir -p "${BACKUP_DIR}/fcitx5/conf"
  cp -a "${FCITX5_CONFIG_DIR}"/conf/*.conf "${BACKUP_DIR}/fcitx5/conf/" 2>/dev/null || true
fi
backup_if_exists "${RIME_USER_DIR}/default.custom.yaml" "rime/default.custom.yaml"
backup_if_exists "${RIME_USER_DIR}/rime_ice.custom.yaml" "rime/rime_ice.custom.yaml"
backup_if_exists "${RIME_USER_DIR}/user.yaml" "rime/user.yaml"

echo "==> 安装 fcitx5 配置"
cp -a "${SCRIPT_DIR}/fcitx5/config" "${FCITX5_CONFIG_DIR}/config"
cp -a "${SCRIPT_DIR}/fcitx5/profile" "${FCITX5_CONFIG_DIR}/profile"
mkdir -p "${FCITX5_CONFIG_DIR}/conf"
cp -a "${SCRIPT_DIR}"/fcitx5/conf/*.conf "${FCITX5_CONFIG_DIR}/conf/"

echo "==> 安装 Rime 用户配置"
cp -a "${SCRIPT_DIR}/rime/default.custom.yaml" "${RIME_USER_DIR}/default.custom.yaml"
cp -a "${SCRIPT_DIR}/rime/rime_ice.custom.yaml" "${RIME_USER_DIR}/rime_ice.custom.yaml"
# 注意：rime/user.yaml.example 仅为结构示例，不覆盖本机 user.yaml

echo ""
echo "安装完成！旧配置已备份到: ${BACKUP_DIR}"
echo ""
echo "后续请手动完成两步："
echo "  1. 重新部署 Rime：在输入法菜单中选择「重新部署」，或执行："
echo "       rm -rf '${RIME_USER_DIR}/build' && fcitx5-remote -r || true"
echo "  2. 重启 fcitx5："
echo "       fcitx5-remote exit 2>/dev/null; fcitx5 -d 2>/dev/null || fcitx5 &"
