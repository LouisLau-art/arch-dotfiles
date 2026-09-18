# Arch Linux + KDE Wayland 新机配置（dotfiles）

本仓库收录 Arch Linux + KDE Wayland 新机从零配置的完整记录，
包含镜像站选择、中文输入法、开发环境、AI 编程助手等全套配置。

## 目录结构

```text
.
├── README.md                    # 本文档
├── bootstrap.sh                 # 全新 Arch 从零安装脚本
├── install.sh                   # 快照恢复脚本（带备份，可重复执行）
├── .gitignore                   # 忽略 Rime 部署产物
├── fcitx5/
│   ├── config                   # fcitx5 全局热键 / 行为
│   ├── profile                  # 输入法分组（Default: rime + keyboard-us）
│   └── conf/*.conf              # 各插件配置（classicui / clipboard / pinyin 等）
├── rime/
│   ├── default.custom.yaml      # 关键补丁：候选数 9 + Shift 直输英文
│   ├── rime_ice.custom.yaml     # 雾凇开关默认（switches/@1/reset: 1）
│   └── user.yaml.example        # user.yaml 脱敏结构示例
│   # 注：wanxiang-lts-zh-hans.gram（约 401MB）仓库不收录，bootstrap.sh [4/5] 下载到 ~/.local/share/fcitx5/rime/
├── zellij/
│   └── config.kdl               # zellij 终端复用器配置
├── zsh/
│   ├── .zshrc                   # zsh 主配置（compinit -C / fzf / atuin / direnv / yazi / carapace）
│   ├── private.zsh.example      # 机密模板（SERPER Key 脱敏，用 YOUR_SERPER_API_KEY_HERE 占位）
│   └── starship.toml            # starship 提示符（nerd 符号 / directory 截断 / 右 prompt 耗时）
├── konsole/
│   ├── Profile 1.profile        # Konsole 配置（Maple Mono NF CN 12pt）
│   └── konsolerc                # Konsole 默认 profile 指向
├── plasma/
│   ├── kdeglobals.beauty.conf   # 仅美化键：Papirus-Dark 图标 + 动画 0.75（kwriteconfig6 恢复）
│   ├── kwinrc.beauty.conf       # 仅美化键：OpenGL 合成 + NightColor 5000/6500K + blur/contrast
│   ├── kscreenlockerrc          # 锁屏幻灯片壁纸（/usr/share/wallpapers，900 秒，可直接覆盖）
│   └── desktop-appletsrc.NOTES.md # appletsrc 不收整文件的原因 + 桌面幻灯片/tray 恢复命令
├── opencode/
│   ├── opencode.json.example    # opencode 主配置（已脱敏）
│   └── oh-my-opencode-slim.json # oh-my-opencode-slim 预设
├── oh-my-opencode/
│   └── oh-my-opencode.json.example # oh-my-opencode 角色模型映射
├── makepkg/
│   ├── makepkg-gh-mirror-curl   # GitHub 镜像下载包装器（makepkg DLAGENT，install.sh 装到 /usr/local/bin）
│   └── github-mirror.conf       # 系统级 drop-in（/etc/makepkg.conf.d/，覆盖 DLAGENTS 的 http/https 下载器）
├── fontconfig/
│   └── fonts.conf               # 字体配置（PingFang SC + Maple Mono NF CN）
└── environment.d/
    ├── input-method.conf        # fcitx5 环境变量
    └── serper.conf              # Serper API Key（已脱敏）
```

## 一键恢复

```bash
git clone <本仓库地址> ~/arch-dotfiles
cd ~/arch-dotfiles
chmod +x install.sh
./install.sh
```

## 全新 Arch 从零安装

```bash
git clone https://github.com/LouisLau-art/arch-dotfiles.git ~/arch-dotfiles
cd ~/arch-dotfiles
chmod +x bootstrap.sh install.sh
./bootstrap.sh   # 内部最后一步会自动调用 install.sh
```

`bootstrap.sh` 做的事（幂等，可重复执行，全程非交互）：

1. **镜像站配置**：自动测试并选择最快的中国镜像站（清华、阿里云、BFSU、华为）
2. **系统包安装**：
   - 基础开发工具：base-devel, git, go, rust, cargo, npm, bun
   - 终端工具：zsh, starship, zellij, bat, eza, zoxide, fd, sd, dust, duf, procs, bottom
   - 终端增强：fzf, atuin, yazi, direnv, carapace-bin（仅 AUR，用 paru 安装）
   - Plasma 美化：papirus-icon-theme, kvantum, qt6ct, plasma-workspace-wallpapers
   - 输入法：fcitx5, fcitx5-rime, rime-ice-git, librime
   - 字体：noto-fonts-cjk, otf-apple-pingfang, ttf-maplemono-nf-cn-unhinted
   - 应用：feishu-bin, wechat-universal-bwrap, linuxqq
3. **环境变量配置**：
   - fcitx5 环境变量（GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS）
   - 代理环境变量（Clash Verge Rev）
   - Go/Python/npm 镜像配置
4. **字体配置**：
   - 系统级：`/etc/fonts/local.conf`
   - 用户级：`~/.config/fontconfig/fonts.conf`
   - 默认无衬线：PingFang SC
   - 默认等宽：Maple Mono NF CN
5. **输入法配置**：
   - fcitx5 配置文件
   - Rime 雾凇方案配置
   - 自启动配置
6. **终端配置**：
   - zsh + 语法高亮 + 自动建议
   - starship 提示符
   - zellij 终端复用器
7. **AI 编程助手配置**：
   - opencode + oh-my-opencode-slim + magic-context
   - lark-cli + 28 个飞书 skills
   - firecrawl-cli + 12 个爬虫 skills
   - serper 搜索 skills

## 核心效果

### 中文输入法

关键补丁来自 `rime/default.custom.yaml`：

```yaml
patch:
  "menu/page_size": 9
  "ascii_composer/switch_key/Shift_L": commit_code
  "ascii_composer/switch_key/Shift_R": commit_code
  schema_list:
    - schema: rime_ice
```

即：候选栏 9 个，左右 Shift 都是「提交原始编码并切英文」。

| 输入 | 按键 | 结果 |
|------|------|------|
| `zidian` | 空格 | 上屏首选中文候选（如「字典」），留在中文模式 |
| `zidian` | 回车 | 上屏首选中文候选，留在中文模式 |
| `zidian` | 左 Shift | 直接上屏英文原文 `zidian`，并切换到英文模式 |
| 中文模式下 | 左 Shift | 在中 / 英文模式之间切换 |

> 记忆口诀：**要中文就空格 / 回车，要英文就左 Shift。**

#### 语法模型（万象 LTS）

方案：`rime_ice` + `librime-plugin-octagram` + 万象 LTS 语法模型 `wanxiang-lts-zh-hans.gram`（约 401MB，amzxyz/RIME-LMDG LTS tag 滚动更新，2026-09-05 版）。
文件由 `bootstrap.sh [4/5]` 负责下载到 `~/.local/share/fcitx5/rime/`，仓库不收录 gram 文件本身。

`rime/rime_ice.custom.yaml` 的 grammar 段（6/3/-14/-6/-100/-20）+ `contextual_suggestions: false` + `max_homophones: 8` 与上游 `others/recipes/grammar.recipe.yaml` 逐行一致；
`translator/dictionary` 挂自建 `rime_ice_plus`（上游逐表 import + 扩展词库，因 librime `import_tables` 不递归）。

生效验证三件套（2026-09-09 实测）：

1. fcitx5 进程 fd mmap 着 `.gram`：
   ```bash
   ls -l /proc/$(pgrep fcitx5)/fd | grep gram
   ```
2. 部署产物含 grammar 声明：
   ```bash
   grep -n "grammar.language" ~/.local/share/fcitx5/rime/build/rime_ice.schema.yaml
   ```
3. 长句连拼看首选整句（短词单字测不出是正常的，模型只在 ≥2 音节无精确匹配时触发组句）：
   - `tayoulianggehaizidouhencongming` → 首选「他有两个孩子都很聪明」
   - `zhejiaqiyefazhanqianlijuda` → 首选「这家企业发展潜力巨大」

版本答案：离线天花板是万象词库 + 自家 gram，当前 ice + gram 已是省心版天花板（差距约 1-2pp 句对率），除非转语句流 / 双拼辅码否则不切。
白霜 rime-frost 是 ice 词库重制版，主攻无模型短词手感，可并行 A/B 共用同一 gram，不迁移；frost 的参数（contextual true 等）是别人家词库方子，别抄。

养词：主 translator 默认开 `user_dict`（无 `enable_user_dict: false` 即启用），已在养，个人词频存 `rime_ice.userdb/`，正常用 2-4 周固化；`melt_eng` 与 `radical_lookup` 的 `false` 保持。备份靠 `sync/` 下与 `installation_id` 同名目录。

单用户说明：fcitx5 是 per-user 守护进程，只有 louis 在跑，root 下无配置无进程，不需要同步；root 误起 fcitx5 会导致 Wayland 失效与权限污染（见 PITFALLS 第 3/15 章）。

维护节奏：LTS tag 内滚动换文件，1-3 个月重下一次即可。

### 快捷键速查

| 功能 | 快捷键 |
|------|--------|
| 切换输入法（中→英→中） | `Super+Space` |
| 中英文快速切换 | `Shift`（左或右） |
| 简繁切换 | `Control+Shift+F` |
| 中英标点切换 | `Control+.` |
| 剪贴板历史 | `Control+;` |
| 方案选单 | `F4` 或 `Control+~` |
| 以词定字 | `[` 取首字 / `]` 取末字 |
| 部件拆字反查 | `uU` + 拼音 |
| 特殊符号 | `v` + 首字母 |
| 计算器 | `cC` + 算式 |
| 日期时间 | `rq`=日期 / `sj`=时间 / `xq`=星期 |

## 开发环境配置

### Shell 配置（~/.zshrc）

```zsh
# 历史记录
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# 插件
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# 补全
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit

# starship 提示符
eval "$(starship init zsh)"

# rust 命令替换
alias cat='bat'
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias find='fd'
alias diff='delta'

# zoxide (cd 智能跳转)
eval "$(zoxide init zsh)"

# opencode omos 函数
omos() {
  local port arg
  for arg in "$@"; do
    if [[ "$arg" == --port=* ]]; then
      port="${arg#--port=}"
      break
    fi
  done
  if [[ -z "$port" ]]; then
    local -a args=("$@")
    local -i index
    for ((index = 1; index <= ${#args}; index++)); do
      if [[ "${args[index]}" == --port ]]; then
        port="${args[index + 1]}"
        break
      fi
    done
  fi
  if [[ -n "$port" ]]; then
    OPENCODE_PORT="$port" command opencode "$@"
    return
  fi
  port=$(python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()') || return
  OPENCODE_PORT="$port" command opencode --port "$port" "$@"
}
```

### Plasma 美化恢复（plasma/ + konsole/）

`install.sh` 用「锁屏全文件覆盖 + `kwriteconfig6` 逐键写入」恢复，不全盘复制含机器 id 的文件：

- 图标 `Papirus-Dark`、动画 `AnimationDurationFactor=0.75`（`kdeglobals.beauty.conf`）
- 合成 `OpenGL` + `blur`/`contrast`、NightColor 自动（白天 6500K / 夜晚 5000K）（`kwinrc.beauty.conf`）
- 桌面幻灯片（`/usr/share/wallpapers`，本机实测 `SlideInterval=5`）与 tray 精简（仅 网络/音量/电池）：`appletsrc` 含 containment id，只收恢复命令，见 `plasma/desktop-appletsrc.NOTES.md`
- 锁屏幻灯片（同壁纸目录，900 秒）：`plasma/kscreenlockerrc` 整文件覆盖
- Konsole：`Maple Mono NF CN 12pt`（`konsole/Profile 1.profile` + `konsolerc`）
- 生效方式：Wayland 下重新登录；或 `kquitapp6 plasmashell && kstart plasmashell`

### AUR 下载加速（makepkg/）

`paru -S` / `makepkg` 从 GitHub Releases 拉源文件常年龟速（直连 ~10KB/s）。仓库收录 curl 包装器，`install.sh` 装到系统级路径，**root/louis 共用一份配置**：

- `/usr/local/bin/makepkg-gh-mirror-curl`：仅改写 GitHub 系域名（github.com / raw / codeload / gist）；依次尝试 `gh-proxy.com` → `ghfast.top` → 直连，镜像 404 或低于 100KB/s 持续 20s 自动淘汰；非 GitHub 源直通
- `/etc/makepkg.conf.d/github-mirror.conf`：覆盖 `DLAGENTS` 的 http/https 下载器（注意用户级 `~/.config/pacman/makepkg.conf` 会覆盖它，别两处都放）
- 实测速度：gh-proxy 3~14MB/s ＞ ghfast ~3MB/s ＞ Clash 代理 ~0.5MB/s ＞ 直连 ~10KB/s（详见 PITFALLS 第 19 条）
- 验证：含 GitHub 源的 PKGBUILD 跑 `makepkg --verifysource -f`，输出应出现 `:: 镜像加速`
- `bootstrap.sh` [4/5] 的 Rime 资源下载与 rime-ice 克隆同样镜像优先

### 字体配置（/etc/fonts/local.conf）

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family"><string>sans-serif</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>PingFang SC</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>serif</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>PingFang SC</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>monospace</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Maple Mono NF CN</string>
    </edit>
  </match>
</fontconfig>
```

### opencode 配置（~/.config/opencode/opencode.jsonc）

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode/mimo-v2.5-free",
  "plugin": [
    "oh-my-opencode-slim",
    "@cortexkit/opencode-magic-context@latest"
  ],
  "agent": {
    "explore": { "disable": true },
    "general": { "disable": true }
  },
  "lsp": true,
  "compaction": { "auto": false, "prune": false }
}
```

### oh-my-opencode-slim 配置（~/.config/opencode/oh-my-opencode-slim.json）

```jsonc
{
  "$schema": "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json",
  "preset": "mimo",
  "multiplexer": { "type": "zellij" },
  "presets": {
    "mimo": {
      "orchestrator": { "model": "opencode/mimo-v2.5-free", "skills": ["*"], "mcps": ["*", "!context7"] },
      "oracle": { "model": "opencode/mimo-v2.5-free", "skills": ["simplify"], "mcps": [] },
      "librarian": { "model": "opencode/mimo-v2.5-free", "skills": [], "mcps": ["context7", "gh_grep"] },
      "explorer": { "model": "opencode/mimo-v2.5-free", "skills": [], "mcps": [] },
      "designer": { "model": "opencode/mimo-v2.5-free", "skills": [], "mcps": [] },
      "fixer": { "model": "opencode/mimo-v2.5-free", "skills": [], "mcps": [] }
    }
  }
}
```

### magic-context 配置（~/.config/cortexkit/magic-context.jsonc）

```jsonc
{
  "$schema": "https://docs.cortexkit.io/magic-context.schema.json",
  "historian": { "opencode": { "model": "opencode/mimo-v2.5-free" } },
  "dreamer": { "opencode": { "model": "opencode/mimo-v2.5-free" } },
  "sidekick": { "model": "opencode/mimo-v2.5-free" }
}
```

## 已安装工具列表

### 系统工具
- **zsh** - Shell
- **starship** - 跨平台提示符
- **zellij** - 终端复用器 v0.45.1
- **base-devel** - 开发工具组
- **git** - 版本控制
- **go** - Go 语言 v1.27
- **rust/cargo** - Rust 工具链
- **npm/bun** - 包管理器

### 终端增强
- **bat** - cat 替代
- **eza** - ls 替代
- **zoxide** - cd 替代
- **fd** - find 替代
- **sd** - sed 替代
- **dust** - du 替代
- **duf** - df 替代
- **procs** - ps 替代
- **bottom** - top 替代
- **git-delta** - diff 增强
- **helix** - 编辑器
- **fzf** - 模糊查找（Ctrl-R/T 键绑定 + fd 后端）
- **atuin** - 历史同步（`--disable-up-arrow`，保留 history-substring-search）
- **yazi** - 终端文件管理器（`y()` 退出自动 cd）
- **direnv** - 目录环境
- **carapace-bin** - 多 shell 补全桥接（仅 AUR，`paru -S carapace-bin`）

### Plasma 美化
- **papirus-icon-theme** - Papirus-Dark 图标主题
- **kvantum / qt6ct** - Qt 主题引擎与配置工具
- **plasma-workspace-wallpapers** - 桌面/锁屏幻灯片壁纸来源（`/usr/share/wallpapers`）

### 输入法
- **fcitx5** - 输入法框架 v5.1.22
- **fcitx5-rime** - Rime 输入法 v5.1.15
- **rime-ice-git** - 雾凇拼音方案

### 字体
- **noto-fonts-cjk** - Noto CJK 字体
- **otf-apple-pingfang** - 苹方字体
- **ttf-maplemono-nf-cn-unhinted** - Maple Mono NF CN

### 应用
- **feishu-bin** - 飞书 v7.72.23
- **wechat-universal-bwrap** - 微信 v4.1.13
- **linuxqq** - QQ v5:3.2.33

### AI 编程助手
- **opencode** - AI 编程助手
- **oh-my-opencode-slim** - 多 agent 插件
- **@cortexkit/opencode-magic-context** - 上下文管理插件
- **lark-cli** - 飞书 CLI v1.0.94
- **firecrawl-cli** - 网页爬虫 CLI v1.23.3

### Skills
- **28 个 lark skills** - 飞书相关操作
- **12 个 firecrawl skills** - 网页爬取和搜索
- **google-serper-search** - Google 搜索
- **serper-search** - Serper 搜索

## 版本基线

| 组件 | 版本 |
|------|------|
| Arch Linux | rolling |
| KDE Plasma | 6.x |
| fcitx5 | 5.1.22 |
| librime | 1:1.17.0 |
| rime-ice | r993.fbb516b（+ librime-plugin-octagram） |
| wanxiang-lts gram | LTS 2026-09-05（约 401MB，bootstrap.sh [4/5] 下载，仓库不收录） |
| zellij | 0.45.1 |
| opencode | 1.18.29 |
| lark-cli | 1.0.94 |
| firecrawl-cli | 1.23.3 |

## 验证与故障排查

```bash
# 检查 fcitx5
pgrep -a fcitx5
fcitx5-diagnose 2>&1 | grep -A2 rime

# 检查字体
fc-match monospace    # 应为 Maple Mono NF CN
fc-match sans-serif   # 应为 PingFang SC

# 检查 opencode
oc --version
oc models

# 检查 lark-cli
lark-cli --version
lark-cli auth status

# 检查 firecrawl
firecrawl --version
firecrawl --status
```

| 症状 | 排查方法 |
|------|----------|
| 候选框不显示 | 查 `GTK_IM_MODULE`；Wayland 确认装了 `fcitx5-frontend-gtk4` |
| 字体显示异常 | `fc-cache -f` 刷新字体缓存 |
| opencode 无法连接 | 检查代理设置，或使用 `oc` 命令（自动带代理） |
| lark-cli 未登录 | `lark-cli auth login` |

## 脱敏说明

- `opencode/opencode.json.example` 含脱敏 API Key 占位符
- `oh-my-opencode/oh-my-opencode.json.example` 含脱敏 API Key 占位符
- `zsh/private.zsh.example` 含脱敏 Serper Key 占位符（旧 key 已泄漏，恢复后务必去 serper.dev 轮换）
- `environment.d/serper.conf` 需替换为真实 API Key
- 所有 `.example` 文件使用方法：复制为同名文件，替换 `YOUR-*-KEY-HERE` 占位符

## 相关链接

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [fcitx5 Wiki](https://wiki.archlinux.org/title/Fcitx5)
- [Rime 雾凇拼音](https://github.com/iDvel/rime-ice)
- [opencode](https://opencode.ai/)
- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
- [magic-context](https://github.com/cortexkit/magic-context)
- [lark-cli](https://github.com/larksuite/cli)
- [firecrawl-cli](https://github.com/firecrawl/cli)
