#!/usr/bin/env bash
# 全新 Ubuntu 从零安装：系统包 + 环境变量 + 自启动 + rime-ice 上游 + 快照覆盖
# 幂等，可重复执行；全程非交互（-y）。合并自旧库 rime-config/deploy.sh，
# 手感配置（custom / fcitx5 快照）仍由 install.sh 覆盖，本脚本只负责“先装上游”。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RIME_DIR="${HOME}/.local/share/fcitx5/rime"
RIME_UPSTREAM="https://github.com/iDvel/rime-ice.git"

if command -v nala >/dev/null 2>&1; then
  INSTALL=(sudo nala install -y)
else
  INSTALL=(sudo apt install -y)
fi

echo "==> [1/5] 安装系统包（fcitx5 + rime + 前后端 + lua/八股文插件）"
"${INSTALL[@]}" \
  fcitx5 fcitx5-rime fcitx5-chinese-addons fcitx5-chinese-addons-data \
  fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 \
  fcitx5-frontend-qt5 fcitx5-frontend-qt6 \
  fcitx5-config-qt fcitx5-module-cloudpinyin \
  fcitx5-module-lua fcitx5-module-lua-common \
  librime-plugin-lua librime-plugin-charcode librime-plugin-octagram

echo "==> [2/5] 环境变量（幂等追加到 ~/.bashrc 与 ~/.profile）"
ENV_LINES='export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export SDL_IM_MODULE=fcitx'
for rc in "${HOME}/.bashrc" "${HOME}/.profile"; do
  touch "${rc}"
  if ! grep -q "GTK_IM_MODULE=fcitx" "${rc}"; then
    printf '%s\n' "${ENV_LINES}" >> "${rc}"
    echo "已追加到 ${rc}"
  else
    echo "已存在，跳过 ${rc}"
  fi
done
# 注意：旧库文档另建议 GLFW_IM_MODULE=ibus（某些应用需要），按需手动加。

echo "==> [3/5] GNOME Wayland 自启动（XDG autostart）"
mkdir -p "${HOME}/.config/autostart"
if [ -f /usr/share/applications/org.fcitx.Fcitx5.desktop ]; then
  cp -f /usr/share/applications/org.fcitx.Fcitx5.desktop "${HOME}/.config/autostart/" || true
  echo "已安装自启动 desktop 文件"
else
  echo "未找到系统 desktop 文件，跳过（包未装好时会出现）"
fi

echo "==> [4/5] rime 增强：万象语言模型 + 扩展词库（幂等，已存在则跳过）"
mkdir -p "${RIME_DIR}"
# 代理可选：本机 Clash 在 127.0.0.1:7897；设置了 https_proxy 就走代理，否则直连
CURL_PROXY=()
if [ -n "${https_proxy:-}" ]; then CURL_PROXY=(--proxy "${https_proxy}"); fi
dl() { # dl <url> <dest>：已存在（非空）则跳过
  if [ -s "$2" ]; then echo "已存在，跳过: $2"; return 0; fi
  echo "下载: $1"
  curl -L --fail "${CURL_PROXY[@]}" -o "$2" "$1"
}
# 1) 万象 LTS 语言模型（octagram grammar，约 400MB；配合 rime_ice.custom.yaml 的 grammar 段）
dl "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram" \
  "${RIME_DIR}/wanxiang-lts-zh-hans.gram"
# 2) 维基百科词库（Arch: pacman 包，装到 /usr/share/rime-data/，含 zhwiki/zhwikisource/zhwiktionary/web-slang）
if command -v pacman >/dev/null 2>&1; then
  pacman -Qq rime-pinyin-zhwiki >/dev/null 2>&1 \
    || sudo pacman -S --noconfirm --needed rime-pinyin-zhwiki
else
  echo "非 Arch 系统：请手动从 felixonmars/fcitx5-pinyin-zhwiki releases 下载 zhwiki*.dict.yaml 到 ${RIME_DIR}"
fi
# 3) 萌娘百科（mw2fcitx release 20260812）
dl "https://github.com/outloudvi/mw2fcitx/releases/download/20260812/moegirl.dict.yaml" \
  "${RIME_DIR}/moegirl.dict.yaml"
# 4) 古诗词（zc0xb/rime-poetry）
dl "https://raw.githubusercontent.com/zc0xb/rime-poetry/master/poetry_pinyin_simp.dict.yaml" \
  "${RIME_DIR}/poetry_pinyin_simp.dict.yaml"
# 5) THUOCL 成语 / IT：raw 数据为「词 空格tab空格 频率」，归一成纯 tab 后包装成 Rime 词库
wrap_thuocl() { # wrap_thuocl <词库名> <url>
  local name="$1" url="$2" out="${RIME_DIR}/${1}.dict.yaml" tmp
  if [ -s "${out}" ]; then echo "已存在，跳过: ${out}"; return 0; fi
  tmp="$(mktemp)"
  curl -L --fail "${CURL_PROXY[@]}" -o "${tmp}" "${url}"
  { printf '# THUOCL (https://github.com/thunlp/THUOCL) wrapped for rime\n---\nname: %s\nversion: "2016"\nsort: by_weight\ncolumns:\n  - text\n  - weight\n...\n' "${name}"
    sed -E 's/ ?\t ?/\t/' "${tmp}"
  } > "${out}"
  rm -f "${tmp}"
  echo "已包装: ${out}"
}
wrap_thuocl chengyu "https://raw.githubusercontent.com/thunlp/THUOCL/master/data/THUOCL_chengyu.txt"
wrap_thuocl it "https://raw.githubusercontent.com/thunlp/THUOCL/master/data/THUOCL_IT.txt"

echo "==> [5/5] rime-ice 上游：已有 .git 则 pull，否则 clone（先上游，后 custom）"
if [ -d "${RIME_DIR}/.git" ]; then
  echo "rime-ice 已存在，pull 更新上游..."
  git -C "${RIME_DIR}" pull
else
  if [ -e "${RIME_DIR}" ]; then
    TS="$(date +%Y%m%d-%H%M%S)"
    mv "${RIME_DIR}" "${HOME}/.local/share/fcitx5/rime-backup-${TS}"
    echo "已有非 git 的 rime 目录，已移走备份到 rime-backup-${TS}"
  fi
  git clone --depth 1 "${RIME_UPSTREAM}" "${RIME_DIR}"
fi

echo "==> 覆盖本仓库快照（调用 install.sh，自带备份）"
bash "${SCRIPT_DIR}/install.sh"

echo ""
echo "✅ 从零安装完成！请重新登录（或 fcitx5 -r -d），再按 README 验证部署。"
