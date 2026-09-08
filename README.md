# fcitx5 + Rime 输入法配置（dotfiles）

本仓库收录本机 fcitx5 + Rime（雾凇 rime-ice）可复现的最小配置骨架，
换机器时一键恢复同样的中英文混输手感；另附 zellij 终端复用器与
opencode / oh-my-opencode 的 AI 编程助手配置。

## 目录结构

```text
.
├── README.md
├── install.sh              # 一键安装脚本（带备份，可重复执行）
├── fcitx5/
│   ├── config              # fcitx5 全局热键 / 行为
│   ├── profile             # 输入法分组（Default: rime + keyboard-us）
│   └── conf/*.conf         # 各插件配置（classicui / clipboard / pinyin 等）
└── rime/
    ├── default.custom.yaml     # 关键补丁：候选数 9 + Shift 直输英文
    ├── rime_ice.custom.yaml    # 雾凇开关默认（switches/@1/reset: 1）
    └── user.yaml.example       # user.yaml 脱敏结构示例（不直接恢复）
├── zellij/
│   └── config.kdl              # zellij 终端复用器键位与布局配置
├── opencode/
│   ├── opencode.json.example           # opencode 主配置（已脱敏，需填密钥后改名使用）
│   └── oh-my-opencode-slim.json        # oh-my-opencode-slim 预设（模型/分工/复用器布局）
└── oh-my-opencode/
    └── oh-my-opencode.json.example     # oh-my-opencode 角色模型映射（已脱敏，需填密钥后改名使用）
```

## 一键恢复

```bash
git clone <本仓库地址> ~/fcitx5-rime-dotfiles
cd ~/fcitx5-rime-dotfiles
chmod +x install.sh
./install.sh
```

脚本做的事：

1. 把旧配置备份到 `~/.config/fcitx5-backup/<时间戳>/`；
2. `fcitx5/config`、`fcitx5/profile`、`fcitx5/conf/*.conf` 复制到 `~/.config/fcitx5/`；
3. `rime/default.custom.yaml`、`rime/rime_ice.custom.yaml` 复制到 `~/.local/share/fcitx5/rime/`；
4. `user.yaml.example` 仅供参考，不覆盖本机 `user.yaml`。
5. `zellij/config.kdl` 复制到 `~/.config/zellij/config.kdl`（旧文件先备份）；
6. `opencode/oh-my-opencode-slim.json` 复制到 `~/.config/opencode/`（旧文件先备份）；
7. `opencode/opencode.json.example`、`oh-my-opencode/oh-my-opencode.json.example`
   仅为脱敏示例，不直接覆盖（脚本会备份本机现有文件并提示手动填密钥）。

装完后手动收尾（脚本最后也会提示）：

```bash
# 1. 重新部署 Rime（推荐在托盘菜单点「重新部署」，或清 build 后重载）
rm -rf ~/.local/share/fcitx5/rime/build && fcitx5-remote -r || true

# 2. 重启 fcitx5
fcitx5-remote exit 2>/dev/null; fcitx5 -d 2>/dev/null || fcitx5 &
```

## 核心效果

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

以敲 `zidian` 为例：

| 输入 | 按键 | 结果 |
|------|------|------|
| `zidian` | 空格 | 上屏首选中文候选（如「字典」），留在中文模式 |
| `zidian` | 回车 | 上屏首选中文候选，留在中文模式 |
| `zidian` | 左 Shift | 直接上屏英文原文 `zidian`，并切换到英文模式 |
| 中文模式下 | 左 Shift | 在中 / 英文模式之间切换（松手即切，不上屏多余字符） |

> 记忆口诀：**要中文就空格 / 回车，要英文就左 Shift。**

`rime/rime_ice.custom.yaml` 另把雾凇第一个开关（`switches/@1`）重置为 `1`，
保证新部署后默认状态一致。

## 皮肤说明

- 皮肤配置就在 `fcitx5/conf/classicui.conf` 里（`Theme=default-dark` / `DarkTheme=default-dark`），已随仓库收录。
- 本机 `~/.config/fcitx5/themes/` 和 `~/.local/share/fcitx5/themes/` 均不存在，用的就是系统自带 `/usr/share/fcitx5/themes/default-dark/`，所以无需额外文件。
- 换机器恢复后如需换肤，只改 `classicui.conf` 的 `Theme=` 并重启 fcitx5 即可；若以后用了自定义皮肤，再把 `~/.local/share/fcitx5/themes/<皮肤名>/` 整个目录收进仓库 `themes/` 即可。

## 新增配置：zellij + opencode

- `zellij/config.kdl`：zellij 终端复用器的自定义键位与界面配置（`clear-defaults` 全量自定义）。
- `opencode/oh-my-opencode-slim.json`：slim 预设的 lane 模型分工与 zellij 复用器布局（main-vertical）。
- `opencode/opencode.json.example`：opencode 主配置，含火山 Ark 与 opencode-zen 两组 provider（密钥已脱敏）。
- `oh-my-opencode/oh-my-opencode.json.example`：各角色（sisyphus / oracle / explorer 等）的模型映射（密钥已脱敏）。

`.example` 文件使用方法：复制为同名 `.json` 放到对应 `~/.config/` 目录，
把 `YOUR-*-KEY-HERE` 替换为自己的真实密钥后再重启对应工具。

## 版本基线

| 组件 | 版本 / 快照 |
|------|-------------|
| fcitx5 | 5.1.14 |
| librime（来自 `installation.yaml` 的 `rime_version`） | 1.13.1 |
| rime-ice 快照 | 2026-02-07 |

不同版本默认值可能变化，若升级后行为异常，优先对比 `default.yaml` /
`rime_ice.schema.yaml` 上游变更后再重新部署。

## 脱敏说明

- `rime/user.yaml.example` 为手写结构示例，`last_build_time` /
  `schema_access_time` 均填 `0` 占位，不含任何机器 ID。
- `installation.yaml` 中的 `installation_id` 未收录，恢复时由 Rime 自动生成。
- `fcitx5/conf/` 下为常规插件配置，不含口令；`~/.config/fcitx5/conf/cached_layouts`
  为巨型缓存文件，未收录。
- `opencode/opencode.json` 含 2 个真实 `apiKey`（火山 Ark + opencode-zen），
  `oh-my-opencode/oh-my-opencode.json` 含 1 个真实 `api_key`，
  故两者均以 `.example` 脱敏收录（密钥替换为 `YOUR-*-KEY-HERE` 占位），不推明文。
- `zellij/config.kdl` 与 `opencode/oh-my-opencode-slim.json` 经 `rg` 扫描无密钥，原样收录。
- `*.bak`、node_modules、`*lock.json` 一律未收录。
