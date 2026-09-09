#!/usr/bin/env bash
# fcitx5 + Rime + zellij + opencode + zsh/starship + konsole + plasma 美化一键恢复脚本（幂等，可重复执行）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

FCITX5_CONFIG_DIR="${HOME}/.config/fcitx5"
RIME_USER_DIR="${HOME}/.local/share/fcitx5/rime"
ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OHMY_CONFIG_DIR="${HOME}/.config/oh-my-opencode"
ZSH_CONFIG_DIR="${HOME}/.config/zsh"
KONSOLE_PROFILE_DIR="${HOME}/.local/share/konsole"

FCITX5_BACKUP="${HOME}/.config/fcitx5-backup/${TIMESTAMP}"
ZELLIJ_BACKUP="${HOME}/.config/zellij-backup/${TIMESTAMP}"
OPENCODE_BACKUP="${HOME}/.config/opencode-backup/${TIMESTAMP}"
OHMY_BACKUP="${HOME}/.config/oh-my-opencode-backup/${TIMESTAMP}"
ZSH_BACKUP="${HOME}/.config/zsh-backup/${TIMESTAMP}"
KONSOLE_BACKUP="${HOME}/.config/konsole-backup/${TIMESTAMP}"
PLASMA_BACKUP="${HOME}/.config/plasma-beauty-backup/${TIMESTAMP}"

mkdir -p "${FCITX5_CONFIG_DIR}" "${RIME_USER_DIR}" \
  "${ZELLIJ_CONFIG_DIR}" "${OPENCODE_CONFIG_DIR}" "${OHMY_CONFIG_DIR}" \
  "${ZSH_CONFIG_DIR}" "${KONSOLE_PROFILE_DIR}" \
  "${FCITX5_BACKUP}" "${ZELLIJ_BACKUP}" "${OPENCODE_BACKUP}" "${OHMY_BACKUP}" \
  "${ZSH_BACKUP}" "${KONSOLE_BACKUP}" "${PLASMA_BACKUP}"

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

backup_to_root "${HOME}/.zshrc" "${ZSH_BACKUP}" "zsh/.zshrc"
backup_to_root "${ZSH_CONFIG_DIR}/private.zsh" "${ZSH_BACKUP}" "zsh/private.zsh"
backup_to_root "${HOME}/.config/starship.toml" "${ZSH_BACKUP}" "zsh/starship.toml"

backup_to_root "${KONSOLE_PROFILE_DIR}/Profile 1.profile" "${KONSOLE_BACKUP}" "konsole/Profile 1.profile"
backup_to_root "${HOME}/.config/konsolerc" "${KONSOLE_BACKUP}" "konsole/konsolerc"

backup_to_root "${HOME}/.config/kdeglobals" "${PLASMA_BACKUP}" "plasma/kdeglobals"
backup_to_root "${HOME}/.config/kwinrc" "${PLASMA_BACKUP}" "plasma/kwinrc"
backup_to_root "${HOME}/.config/kscreenlockerrc" "${PLASMA_BACKUP}" "plasma/kscreenlockerrc"
backup_to_root "${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc" "${PLASMA_BACKUP}" "plasma/plasma-org.kde.plasma.desktop-appletsrc"

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
# rime_ice_plus 词库合集（配合 rime_ice.custom.yaml 的 "translator/dictionary": rime_ice_plus；
# 引用的扩展词库文件由 bootstrap.sh [4/5] 下载到本目录）
cp -a "${SCRIPT_DIR}/rime/rime_ice_plus.dict.yaml" "${RIME_USER_DIR}/rime_ice_plus.dict.yaml"
# 注意：rime/user.yaml.example 仅为结构示例，不覆盖本机 user.yaml

echo "==> 安装 zellij 配置"
cp -a "${SCRIPT_DIR}/zellij/config.kdl" "${ZELLIJ_CONFIG_DIR}/config.kdl"

echo "==> 安装 zsh / starship 配置"
cp -a "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
cp -a "${SCRIPT_DIR}/zsh/starship.toml" "${HOME}/.config/starship.toml"
# 注意：zsh/private.zsh.example 为脱敏模板（含 YOUR_SERPER_API_KEY_HERE 占位），不直接覆盖本机真实密钥文件。
# 如需恢复，请手动复制并填入密钥，例如：
#   cp zsh/private.zsh.example ~/.config/zsh/private.zsh && chmod 600 ~/.config/zsh/private.zsh
# （本机现有文件已在上面备份，可放心操作；旧 key 已泄漏，务必去 serper.dev 轮换）

echo "==> 安装 Konsole 配置（Maple Mono NF CN 12pt）"
cp -a "${SCRIPT_DIR}/konsole/Profile 1.profile" "${KONSOLE_PROFILE_DIR}/Profile 1.profile"
cp -a "${SCRIPT_DIR}/konsole/konsolerc" "${HOME}/.config/konsolerc"

echo "==> 安装 Plasma 美化（锁屏全文件覆盖 + kwriteconfig6 逐键写入，幂等）"
cp -a "${SCRIPT_DIR}/plasma/kscreenlockerrc" "${HOME}/.config/kscreenlockerrc"
if command -v kwriteconfig6 >/dev/null 2>&1; then
  # kdeglobals：Papirus-Dark 图标 + 动画 0.75（见 plasma/kdeglobals.beauty.conf）
  kwriteconfig6 --file kdeglobals --group Icons --key Theme "Papirus-Dark"
  kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor "0.75"
  kwriteconfig6 --file kdeglobals --group KDE --key contrast "7"
  # kwinrc：OpenGL 合成 + NightColor 自动 5000/6500K + blur/contrast（见 plasma/kwinrc.beauty.conf）
  kwriteconfig6 --file kwinrc --group Compositing --key Backend "OpenGL"
  kwriteconfig6 --file kwinrc --group Compositing --key Enabled "true"
  kwriteconfig6 --file kwinrc --group NightColor --key Active "true"
  kwriteconfig6 --file kwinrc --group NightColor --key DayTemperature "6500"
  kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature "5000"
  kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled "true"
  kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled "true"
  # 桌面幻灯片壁纸 + tray 精简（整文件不收录，原因见 plasma/desktop-appletsrc.NOTES.md；
  # 桌面端 SlideInterval=5 为本机实测值，锁屏端 900 已随 kscreenlockerrc 覆盖）
  kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
    --group Containments --group 1 --key wallpaperplugin "org.kde.slideshow"
  kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
    --group Containments --group 1 --group Wallpaper --group org.kde.slideshow --group General \
    --key SlidePaths "/usr/share/wallpapers"
  kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
    --group Containments --group 1 --group Wallpaper --group org.kde.slideshow --group General \
    --key SlideInterval "5"
  kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
    --group Containments --group 2 --group Applets --group 7 --group General \
    --key shownItems "org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.battery"
else
  echo "提示: 未找到 kwriteconfig6，跳过 kdeglobals/kwinrc/appletsrc 逐键写入；请进 Plasma 系统设置手动调整，或见 plasma/desktop-appletsrc.NOTES.md。"
fi

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
echo "  zsh/starship:         ${ZSH_BACKUP}"
echo "  konsole:              ${KONSOLE_BACKUP}"
echo "  plasma 美化:          ${PLASMA_BACKUP}"
echo ""
echo "后续请手动完成："
echo "  1. 重新部署 Rime：在输入法菜单中选择「重新部署」，或执行："
echo "       rm -rf '${RIME_USER_DIR}/build' && fcitx5-remote -r || true"
echo "  2. 重启 fcitx5："
echo "       fcitx5-remote exit 2>/dev/null; fcitx5 -d 2>/dev/null || fcitx5 &"
echo "  3. 如需启用 .example：按上方注释复制并填入真实密钥。"
echo "  4. Plasma 美化即时生效：重新登录（Wayland 下推荐）；或执行"
echo "       kquitapp6 plasmashell && kstart plasmashell"
echo "     刷新桌面壁纸与托盘；NightColor/Compositing 改动建议直接重新登录。"
