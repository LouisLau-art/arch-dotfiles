#!/usr/bin/env bash
# fcitx5 + Rime + zellij + opencode 一键恢复脚本（幂等，可重复执行）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

FCITX5_CONFIG_DIR="${HOME}/.config/fcitx5"
RIME_USER_DIR="${HOME}/.local/share/fcitx5/rime"
ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OHMY_CONFIG_DIR="${HOME}/.config/oh-my-opencode"

FCITX5_BACKUP="${HOME}/.config/fcitx5-backup/${TIMESTAMP}"
ZELLIJ_BACKUP="${HOME}/.config/zellij-backup/${TIMESTAMP}"
OPENCODE_BACKUP="${HOME}/.config/opencode-backup/${TIMESTAMP}"
OHMY_BACKUP="${HOME}/.config/oh-my-opencode-backup/${TIMESTAMP}"

mkdir -p "${FCITX5_CONFIG_DIR}" "${RIME_USER_DIR}" \
  "${ZELLIJ_CONFIG_DIR}" "${OPENCODE_CONFIG_DIR}" "${OHMY_CONFIG_DIR}" \
  "${FCITX5_BACKUP}" "${ZELLIJ_BACKUP}" "${OPENCODE_BACKUP}" "${OHMY_BACKUP}"

# backup_to_root <本机文件> <备份根目录> <备份内相对路径>
backup_to_root() {
  local src="$1" root="$2" rel="$3"
  if [ -e "${src}" ]; then
    mkdir -p "${root}/$(dirname "${rel}")"
    cp -a "${src}" "${root}/${rel}"
    echo "已备份: ${src} -> ${root}/${rel}"
  fi
}

echo "==> 备份旧配置（时间戳 ${TIMESTAMP}）"

backup_to_root "${FCITX5_CONFIG_DIR}/config" "${FCITX5_BACKUP}" "fcitx5/config"
backup_to_root "${FCITX5_CONFIG_DIR}/profile" "${FCITX5_BACKUP}" "fcitx5/profile"
if [ -d "${FCITX5_CONFIG_DIR}/conf" ]; then
  mkdir -p "${FCITX5_BACKUP}/fcitx5/conf"
  cp -a "${FCITX5_CONFIG_DIR}"/conf/*.conf "${FCITX5_BACKUP}/fcitx5/conf/" 2>/dev/null || true
fi
backup_to_root "${RIME_USER_DIR}/default.custom.yaml" "${FCITX5_BACKUP}" "rime/default.custom.yaml"
backup_to_root "${RIME_USER_DIR}/rime_ice.custom.yaml" "${FCITX5_BACKUP}" "rime/rime_ice.custom.yaml"
backup_to_root "${RIME_USER_DIR}/user.yaml" "${FCITX5_BACKUP}" "rime/user.yaml"

backup_to_root "${ZELLIJ_CONFIG_DIR}/config.kdl" "${ZELLIJ_BACKUP}" "zellij/config.kdl"
backup_to_root "${OPENCODE_CONFIG_DIR}/opencode.json" "${OPENCODE_BACKUP}" "opencode/opencode.json"
backup_to_root "${OPENCODE_CONFIG_DIR}/oh-my-opencode-slim.json" "${OPENCODE_BACKUP}" "opencode/oh-my-opencode-slim.json"
backup_to_root "${OHMY_CONFIG_DIR}/oh-my-opencode.json" "${OHMY_BACKUP}" "oh-my-opencode/oh-my-opencode.json"

echo "==> 安装 fcitx5 配置"
cp -a "${SCRIPT_DIR}/fcitx5/config" "${FCITX5_CONFIG_DIR}/config"
cp -a "${SCRIPT_DIR}/fcitx5/profile" "${FCITX5_CONFIG_DIR}/profile"
mkdir -p "${FCITX5_CONFIG_DIR}/conf"
cp -a "${SCRIPT_DIR}"/fcitx5/conf/*.conf "${FCITX5_CONFIG_DIR}/conf/"

echo "==> 安装 Rime 用户配置"
if [ ! -f "${RIME_USER_DIR}/default.yaml" ]; then
  echo "提示: 未检测到 rime-ice 上游（缺 default.yaml），全新机器请先运行 ./bootstrap.sh 拉上游再覆盖 custom；此处仍会写入 custom 文件。"
fi
cp -a "${SCRIPT_DIR}/rime/default.custom.yaml" "${RIME_USER_DIR}/default.custom.yaml"
cp -a "${SCRIPT_DIR}/rime/rime_ice.custom.yaml" "${RIME_USER_DIR}/rime_ice.custom.yaml"
# 注意：rime/user.yaml.example 仅为结构示例，不覆盖本机 user.yaml

echo "==> 安装 zellij 配置"
cp -a "${SCRIPT_DIR}/zellij/config.kdl" "${ZELLIJ_CONFIG_DIR}/config.kdl"

echo "==> 安装 opencode / oh-my-opencode 配置"
cp -a "${SCRIPT_DIR}/opencode/oh-my-opencode-slim.json" "${OPENCODE_CONFIG_DIR}/oh-my-opencode-slim.json"
# 注意：opencode/opencode.json.example 与 oh-my-opencode/oh-my-opencode.json.example
# 为脱敏示例（含 YOUR-*-KEY-HERE 占位），不直接覆盖本机真实密钥文件。
# 如需恢复，请手动复制并填入密钥，例如：
#   cp opencode/opencode.json.example ~/.config/opencode/opencode.json
#   cp oh-my-opencode/oh-my-opencode.json.example ~/.config/oh-my-opencode/oh-my-opencode.json
# （本机现有文件已在上面备份，可放心操作）

echo ""
echo "安装完成！备份位置："
echo "  fcitx5/opencode 前身: ${FCITX5_BACKUP}"
echo "  zellij:               ${ZELLIJ_BACKUP}"
echo "  opencode:             ${OPENCODE_BACKUP}"
echo "  oh-my-opencode:       ${OHMY_BACKUP}"
echo ""
echo "后续请手动完成："
echo "  1. 重新部署 Rime：在输入法菜单中选择「重新部署」，或执行："
echo "       rm -rf '${RIME_USER_DIR}/build' && fcitx5-remote -r || true"
echo "  2. 重启 fcitx5："
echo "       fcitx5-remote exit 2>/dev/null; fcitx5 -d 2>/dev/null || fcitx5 &"
echo "  3. 如需启用 .example：按上方注释复制并填入真实密钥。"
