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
