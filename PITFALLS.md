# 踩坑记录

Arch Linux + KDE Wayland 新机配置过程中遇到的问题和解决方案。

## 1. 镜像站速度问题

**问题**：默认镜像站速度慢， pacman 下载龟速。

**解决**：
- 用 `rate-mirrors` 或手动测试脚本筛选最快镜像
- 中国用户推荐：清华TUNA、阿里云、BFSU、华为
- archlinuxcn 仓库用 BFSU 镜像：`Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch`

**坑**：
- 不要用代理去测国内镜像速度，结果不准
- XferCommand 不要改，保持默认的 wget/curl

## 2. Muse Spark 模型被墙

**问题**：`opencode/muse-spark-1.3-contributor-free` 提示 "This model is not available in your country"

**原因**：Meta 对中国（包括台湾）地区限制，API 端检测 IP 归属地。

**解决**：
- 走代理可以绕过：`http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 opencode run ...`
- 或者换用其他免费模型：`opencode/mimo-v2.5-free`

**坑**：
- Clash Verge Rev 设了系统代理，但 opencode 不认，需要手动设环境变量
- TUN 模式可以自动走代理，但用户可能不想开

## 3. fcitx5 通过 sudo 重启后中文输入失效

**问题**：通过 `sudo` 重启 fcitx5 后，进程在但中文输入不工作——Konsole、Qt6、GTK4 等 Wayland 原生应用无法切换中文输入，只有 XWayland 应用正常。

**原因**：
- `sudo` 默认启用 `env_reset`，会清除 `WAYLAND_DISPLAY` 环境变量
- fcitx5 失去 `WAYLAND_DISPLAY` 后只能走 X11 后端，无法向 KWin 注册为 Wayland 输入法
- 因此 Wayland 原生应用（Konsole、Qt6、GTK4）收不到中文输入
- dbus/dbus-broker 一直在正常运行，问题不在 dbus

**解决**：
- 启动 fcitx5 时必须带上完整环境变量：
  ```bash
  sudo -u louis env \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    XDG_RUNTIME_DIR="/run/user/$(id -u louis)" \
    XMODIFIERS=@im=fcitx \
    GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    fcitx5 -d
  ```
- 或者用 systemd user service：`systemctl --user restart fcitx5`
- 绝对不要用裸的 `sudo -u louis fcitx5 -d`

**坑**：
- 环境变量 `WAYLAND_DISPLAY`、`XDG_RUNTIME_DIR` 是 Wayland 输入法工作的前提
- `XMODIFIERS`、`GTK_IM_MODULE`、`QT_IM_MODULE` 三个缺一不可
- 通过 SSH 或 `sudo` 进入的 session 不会自动继承这些变量

## 4. zsh/omos 函数不可用

**问题**：重启后 shell 是 bash，`omos` 命令找不到。

**原因**：
- 虽然 `/etc/passwd` 里 louis 的 shell 是 zsh，但当前终端 session 还是 bash
- `omos` 函数定义在 `~/.zshrc` 里，bash 不会读

**解决**：
- 登出再登入，或者开新终端
- 或者手动 `source ~/.zshrc`

**坑**：
- 修改 `/etc/passwd` 后需要重新登录才生效
- 当前 session 不会自动切换 shell

## 5. SSH key 权限问题

**问题**：生成 SSH key 时提示 "Permission denied"

**原因**：`/home/louis/.ssh/` 目录是 root 创建的，owner 是 root。

**解决**：
- `chown -R louis:louis /home/louis/.ssh/`
- 然后重新生成 key

**坑**：
- 用 `sudo -u louis` 执行命令，但目录权限不对还是会失败
- `ssh-keygen` 写文件时会检查目录 owner

## 6. Git 推送失败

**问题**：`git push` 提示 "Host key verification failed"

**原因**：`~/.ssh/known_hosts` 里没有 GitHub 的 host key。

**解决**：
- `ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts`

**坑**：
- 新装系统没有 known_hosts 文件
- 用 `sudo -u louis` 执行时，known_hosts 路径会指向 root 的

## 7. 字体配置不生效

**问题**：`fc-match monospace` 显示 Noto Sans Mono，不是 Maple Mono。

**原因**：`<alias>` + `<prefer>` 语法不够强，无法覆盖系统默认。

**解决**：用 `<match>` + `binding="strong"` 强制覆盖：
```xml
<match target="pattern">
  <test name="family"><string>monospace</string></test>
  <edit name="family" mode="prepend" binding="strong">
    <string>Maple Mono NF CN</string>
  </edit>
</match>
```

**坑**：
- fontconfig 的 `<alias>` 语法看起来对，但实际不生效
- 需要用 `<match>` 才能强制覆盖

## 8. 代理环境变量全局污染

**问题**：设了全局 `HTTP_PROXY`，导致国内网站（Gitee、npm 镜像）也走代理。

**解决**：
- 不设全局代理，让 Clash Verge Rev 的规则引擎处理
- 特定工具需要代理时单独加：`http_proxy=... opencode run ...`
- 或者用 `oc` alias 封装

**坑**：
- 手动维护 `NO_PROXY` 列表是无底洞
- Clash Verge Rev 的 TUN 模式可以自动处理，但用户可能不想开

## 9. magic-context setup 交互式

**问题**：`npx @cortexkit/magic-context@latest setup` 需要交互选择模型。

**解决**：
- 手动创建 `~/.config/cortexkit/magic-context.jsonc`
- 配置 historian/dreamer/sidekick 的模型

**坑**：
- 非交互终端里没法用 `setup` 向导
- 需要手动写配置文件

## 10. skills 安装位置问题

**问题**：`npx skills add` 默认装到项目级，不是全局。

**解决**：加 `-g` 标志安装到全局：
```bash
npx skills add "larksuite/cli" --all -g
```

**坑**：
- 全局 skills 装到 `~/.agents/skills/`
- 某些 agent（如 Eve、PromptScript）不支持全局安装，会报错但不影响其他

## 11. lark-cli postinstall 被拦

**问题**：`npm install -g @larksuite/cli` 后 postinstall 脚本没执行。

**解决**：
```bash
npm install -g @larksuite/cli --allow-scripts=@larksuite/cli
```

**坑**：
- npm 默认阻止 postinstall 脚本
- 需要显式允许

## 12. gh 推送认证问题

**问题**：`gh auth` 用的是 SSH 协议，但 git remote 是 HTTPS，两边不匹配。

**解决**：
- `git remote set-url origin git@github.com:user/repo.git`
- 或者用 `gh auth setup-git` 配置 HTTPS 认证

**坑**：
- `gh auth status` 显示的协议和 git 实际用的可能不一样
- 需要手动对齐

## 13. Zen Browser 关闭后 Cookie 丢失

**问题**：Zen Browser 每次关闭或重启后，所有 Cookie 都没了。

**原因**：Zen 默认开启 `privacy.sanitize.sanitizeOnShutdown: true`，关闭时自动清除 Cookie 和缓存。

**解决**：修改 `~/.config/zen/<profile>/prefs.js`：

```js
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.clearOnShutdown.offlineApps", false);
user_pref("privacy.sanitize.pending", "[]");
```

**坑**：
- 这是 Zen Browser 的默认行为，不是 bug
- 必须先关闭浏览器再改 prefs.js，否则会被覆盖
- 修改后需要重启浏览器生效

## 14. Zen Browser 图标显示为 Firefox

**问题**：KDE 任务栏里 Zen Browser 显示 Firefox 图标。

**原因**：
1. `application.ini` 里 `Name=Firefox`，窗口标题也叫 "Firefox"
2. desktop 文件里 `StartupWMClass=zen`，但实际 WMClass 是 `zen-browser`
3. WMClass 不匹配导致图标匹配失败

**解决**：修改 `/usr/share/applications/zen-browser.desktop`：

```ini
StartupWMClass=zen-browser  # 原来是 zen
```

**坑**：
- `application.ini` 有注释说"不建议直接改"，改了可能影响浏览器行为
- 窗口标题 "Firefox" 改不了（是 Zen 内部的）
- 更新 Zen 后 desktop 文件可能被覆盖，需要重新改

## 15. fcitx5 配置目录权限被 root 覆盖

**问题**：fcitx5 保存配置时报 `Permission denied`，配置无法写入。

**原因**：某次以 root 身份启动了 fcitx5（或通过 root session 操作了配置），导致 `~/.config/fcitx5/` 下的文件和目录 owner 变成 root。

**解决**：
```bash
chown -R louis:louis ~/.config/fcitx5/
```

**坑**：
- 用 `sudo fcitx5 -d` 启动后，fcitx5 会在运行过程中写入配置（如词频、模糊音），这些文件都会变成 root 所有
- 即使后来切回 louis 用户正常启动 fcitx5，配置文件权限已经坏了
- 可以用 `find ~/.config/fcitx5/ -user root` 检查是否还有残留的 root 文件

## 16. NetworkManager 自动 DNS 分配不可达的 nameserver

**问题**：DNS 间歇性失败，部分应用（如 pacman、curl）能解析，部分应用（如 Firefox、opencode）超时。

**原因**：
- NetworkManager 通过 DHCP 自动获取了运营商分配的 nameserver（如 `218.104.111.122`、`114.114.114.114`）
- 这些 nameserver 实际不可达或响应极慢，导致 DNS 查询超时
- 不同应用的 DNS 解析行为不同：有的用系统 resolver（走 `/etc/resolv.conf`），有的用 `getaddrinfo` 配合不同的超时策略，所以表现不一致

**解决**：
```bash
# 设置可靠的 DNS 服务器（阿里 + 腾讯 DoT），并忽略 DHCP 分配的 DNS
nmcli con mod QINKUNG ipv4.dns "223.5.5.5 182.254.42.2"
nmcli con mod QINKUNG ipv4.ignore-auto-dns yes
# 重新激活连接使配置生效
nmcli con up QINKUNG
```

**坑**：
- `218.104.111.122` 是某些地区运营商 DNS，看似合理但经常超时
- `114.114.114.114` 是国内公共 DNS，但部分地区路由不可达
- 只有重启连接（`nmcli con up`）才能让新 DNS 生效，`resolvectl flush-caches` 不够
- 可以用 `resolvectl status` 确认当前使用的 nameserver 列表

## 17. 飞书桌面端白屏

**问题**：飞书桌面端（`/usr/bin/bytedance-feishu-stable` → `/opt/bytedance/feishu/feishu`）启动后整个窗口白屏，无法登录使用。

**原因**：
- 飞书客户端内置的 ttnet SDK 硬编码了 DoH（DNS over HTTPS）服务器，走 Google IPv6 地址 `2001:4860:4860::8888:443`
- 该地址在大陆不可达 → 域名解析失败（netlog 中大量 `-105 NAME_NOT_RESOLVED` / `-109 ADDRESS_UNREACHABLE`）→ 白屏
- `--disable-features=DnsOverHttps` 等 flag 管不住 ttnet 内部的 DoH，改启动参数没用
- 问题间歇性：2026-09-08 当天 16:55 重启后由 autostart 正常拉起（无代理 env、临时 iptables 规则已消失），一切正常 → 自愈/间歇性。系统 DNS 已固定 223.5.5.5 + 182.254.42.2（见第 16 章）

**解决**（复发预案，按顺序试）：

a. 临时 REJECT 该 DoH 地址，让 ttnet 的 DoH 快速失败、促其回退系统 DNS（重启即失效，故意不持久化）：
```bash
ip6tables -I OUTPUT 1 -d 2001:4860:4860::8888/128 -j REJECT
```

b. 杀掉飞书后带代理 env 重启（`<当前xauth>` 用 `ls /run/user/1000/xauth_*` 取当前值后替换）：
```bash
sudo -u louis env HOME=/home/louis USER=louis LOGNAME=louis XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus DISPLAY=:1 XAUTHORITY=<当前xauth> WAYLAND_DISPLAY=wayland-0 XDG_SESSION_TYPE=wayland http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 ALL_PROXY=socks5://127.0.0.1:7897 setsid /usr/bin/feishu &
```

c. 官方方案（GUI，最持久）：飞书 设置 → 网络 → 代理，填 `127.0.0.1:7897`

d. 复发时采集 netlog 诊断：
```bash
/usr/bin/feishu --log-net-log=/tmp/feishu-netlog.json
```

**坑**：
- 白屏根因在 ttnet 内部 DoH，不是系统 DNS——`--disable-features=DnsOverHttps`、改启动 flag 都不一定管用
- REJECT 规则只临时加（`-I`），不要持久化，避免长期影响正常网络
- 带 env 重启时环境变量必须齐全（同第 3 章教训），缺 `WAYLAND_DISPLAY`/`XDG_RUNTIME_DIR` 等会起不来或输入法失效
- 问题会间歇性自愈，复发时先按预案处理，别急着改系统配置

## 18. 重启后感觉语法模型没生效

**症状**：短词单字打什么都一样，感觉模型没起作用；但长句连拼首选是稳的。

**排查三步**（按顺序跑）：

1. fcitx5 是否 mmap 着 `.gram`：
   ```bash
   ls -l /proc/$(pgrep fcitx5)/fd | grep gram
   ```
   无输出 = 模型没加载。
2. 部署产物是否含 grammar 声明：
   ```bash
   grep -n "grammar.language" ~/.local/share/fcitx5/rime/build/rime_ice.schema.yaml
   ```
   无输出 = 部署被覆盖 / 没重新部署。
3. 长句对照（只看首选整句，短词不算）：
   - `tayoulianggehaizidouhencongming` → 应首选「他有两个孩子都很聪明」
   - `zhejiaqiyefazhanqianlijuda` → 应首选「这家企业发展潜力巨大」

**根因**：
- 大多是期望错位：单字短词必然无差，模型只在 ≥2 音节无精确匹配时触发组句，短词测不出是正常的。
- 若长句也不对，再查两件事：是否 root 误起了 fcitx5（进程用户错了）；`build/` 是否被重部署覆盖（重跑一次部署再查第 2 步）。

**明确不要动的**：
- `collocation_penalty` / `non_collocation_penalty` / `weak_collocation_penalty` / `rear_penalty` 等 penalty 参数
- `contextual_suggestions: false`（frost 的 true 是别人家词库方子，别抄）
- 不要换 gram 文件、不要加云插件，当前 ice + 万象 LTS 已是省心版天花板

详见第 3 章（sudo 重启失效）与第 15 章（root 权限污染）。

## 19. AUR / paru 从 GitHub 下载龟速

**问题**：`paru -S <包>` 卡在 `Downloading xxx.tar.xz`，大包（如 beekeeper-studio 196MB）只有 12KB/s、ETA 4 小时。

**原因**：PKGBUILD 的 `source` 指向 `github.com/*/releases/download/*` 等 GitHub 资源，国内直连常年十几 KB/s；makepkg 默认不走代理，而 Clash(7897) 实测也只有 ~0.5MB/s。

**解决**（系统级一次配置，root/louis/新用户都生效；仓库 `makepkg/` 收录，install.sh 自动恢复）：
- wrapper `/usr/local/bin/makepkg-gh-mirror-curl` + drop-in `/etc/makepkg.conf.d/github-mirror.conf`（覆盖 `DLAGENTS` 的 http/https 下载器）
- 行为：GitHub 系 URL 依次试 `gh-proxy.com` → `ghfast.top` → 直连；镜像 404 或低于 100KB/s 持续 20s 自动换下一个；非 GitHub 源零开销直通
- 实测：gh-proxy 3~14MB/s ＞ ghfast ~3MB/s ＞ Clash 代理 ~0.5MB/s ＞ 直连 ~10KB/s
- `bootstrap.sh` 第 [4/5] 步的 `dl()` / `wrap_thuocl()` 与 rime-ice 克隆同样改为镜像优先

**应急**（不改配置，把源文件预热进 paru 构建目录即可）：

```bash
dir=~/.cache/paru/clone/<包名>
grep -A5 '^source' "$dir/PKGBUILD"      # 注意 `文件名::URL` 语法，落地名取 :: 左边
curl -L -o "$dir/<文件名>" "https://gh-proxy.com/<原始URL>"
sha256sum "$dir/<文件名>"               # 必须与 PKGBUILD 的 sha256sums(_$CARCH) 一致
```

Ctrl+C 后重跑 paru，makepkg 见同名文件直接 `Found` 跳过下载（只认最终文件名；`.part` 残留可删）。

**坑**：
- 预热文件校验和必须匹配，否则 makepkg 重新下载；属主要与构建用户一致（构建目录出现过 root 属主文件）
- ghproxy.net 别用（实测 4KB/s，会被限速阈值淘汰）
- VCS 源（-git 包）走 `git clone`，不经 DLAGENTS，本方案覆盖不到（makepkg 还会屏蔽用户级 git 配置）
- `~/.config/pacman/makepkg.conf` 会覆盖系统级 drop-in，同一项别两处都放

---

## 通用教训

1. **重启后检查一切**：修改 shell、环境变量、自启动配置后，必须重启验证
2. **fcitx5 需要完整环境**：`WAYLAND_DISPLAY`、`XMODIFIERS`、`GTK_IM_MODULE`、`QT_IM_MODULE` 缺一不可，别裸用 `sudo -u xxx fcitx5 -d`
3. **代理不要全局设**：让 Clash Verge Rev 的规则引擎处理，别手动维护 NO_PROXY
4. **字体配置用 match**：`<alias>` 不够强，用 `<match binding="strong">`
5. **SSH key 权限**：生成前先检查目录 owner
6. **skills 装全局**：加 `-g`，不然只有当前项目能用
7. **root 操作后检查文件权限**：root session 写过的配置目录用 `chown -R` 修复
8. **DNS 问题用 `resolvectl status` 排查**：看到不可达的 nameserver 就用 `nmcli` 覆盖
9. **语法模型只看长句首选，短词测不出**：单字短词必然无差，验证只看长句连拼首选整句
10. **GitHub 大文件优先走 gh-proxy 镜像**：实测 3~14MB/s，比直连快三个数量级、比代理快一个数量级；AUR/makepkg/bootstrap 均已接入（第 19 条）
