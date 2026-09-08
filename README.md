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
├── zellij/
│   └── config.kdl               # zellij 终端复用器配置
├── opencode/
│   ├── opencode.json.example    # opencode 主配置（已脱敏）
│   └── oh-my-opencode-slim.json # oh-my-opencode-slim 预设
├── oh-my-opencode/
│   └── oh-my-opencode.json.example # oh-my-opencode 角色模型映射
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
| rime-ice | r993.fbb516b |
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
