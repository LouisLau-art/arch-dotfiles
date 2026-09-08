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

## 3. fcitx5 重启后 rime 不工作

**问题**：重启后 fcitx5 进程在，但 rime 没加载，提示 dbus 冲突。

**原因**：
- dbus-daemon 没有为 louis 用户启动
- fcitx5 需要 dbus 才能正常工作
- 以 root 身份运行 fcitx5 会和用户级 dbus 冲突

**解决**：
- 用 `machinectl shell louis@ /bin/bash -c "fcitx5 -d"` 以 louis 用户启动
- 或者检查 systemd user service：`systemctl --user status fcitx5`

**坑**：
- root 和 louis 的 dbus session 是隔离的
- `killall fcitx5` 后重启，dbus 名字可能还被占着

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

---

## 通用教训

1. **重启后检查一切**：修改 shell、环境变量、自启动配置后，必须重启验证
2. **dbus 是大坑**：Linux 桌面的 dbus session 管理很复杂，root 和用户隔离
3. **代理不要全局设**：让 Clash Verge Rev 的规则引擎处理，别手动维护 NO_PROXY
4. **字体配置用 match**：`<alias>` 不够强，用 `<match binding="strong">`
5. **SSH key 权限**：生成前先检查目录 owner
6. **skills 装全局**：加 `-g`，不然只有当前项目能用
