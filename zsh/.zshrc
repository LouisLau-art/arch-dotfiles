# ============================================================
# .zshrc - louis
# ============================================================

# --- 历史记录 ---
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# --- 插件 ---
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# --- 补全 (优化: -C 跳过全量安全检查,自定义 dump 路径,后台编译加速) ---
mkdir -p ~/.cache/zsh
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit -C -d ~/.cache/zsh/zcompdump
# dump 有更新时重新编译,下次加载更快 (静默失败不影响启动)
{ [[ ~/.cache/zsh/zcompdump.zwc -ot ~/.cache/zsh/zcompdump ]] && zcompile ~/.cache/zsh/zcompdump & } 2>/dev/null

# --- 机密 (守卫 source,缺失时提醒;旧 key 已泄漏,务必轮换,键名见 private.zsh) ---
[[ -f ~/.config/zsh/private.zsh ]] && source ~/.config/zsh/private.zsh
[[ -f ~/.config/zsh/private.zsh ]] || echo "提醒: 私密 key 未设置,请检查 ~/.config/zsh/private.zsh (旧 key 已泄漏,需轮换)" >&2

# --- starship 提示符 ---
eval "$(starship init zsh)"

# --- rust 命令替换 (核心) ---
alias cat='bat'
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons'
alias find='fd'
alias rg='rg --hidden --glob "!.git"'
alias sed='sd'
alias du='dust'
alias df='duf'
alias ps='procs'
alias top='btm'
alias tree='broot'
alias curl='xh'
alias cut='choose'
alias diff='delta'
alias grep='rg'
alias loc='tokei'

# --- zoxide (cd 智能跳转) ---
eval "$(zoxide init zsh)"

# --- fzf (键绑定 Ctrl-R/T + 补全,守卫缺失) ---
if (( $+commands[fzf] )); then
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  (( $+commands[fd] )) && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi

# --- atuin (历史同步,禁用 up-arrow 以保留 history-substring-search) ---
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# --- direnv (目录环境,守卫缺失) ---
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# --- carapace (多 shell 补全桥接,必须在 compinit 之后,守卫缺失) ---
if (( $+commands[carapace] )); then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

# --- yazi (ya 包装:退出时 cd 到最后目录) ---
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp" && [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# --- 常用快捷键 ---
alias vim='hx'
alias vi='hx'
alias python='python3'
alias pip='python3 -m pip'
alias cls='clear'

# --- 编辑器 ---
export EDITOR=hx
export VISUAL=hx

# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

# --- Go 环境 ---
export GOPATH="$HOME/go"
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=sum.golang.google.cn
export GO111MODULE=on
export PATH="$HOME/.bun/bin:$PATH"

# --- opencode omos ---
# muse-spark 等 Meta 地区受限模型需要走 Clash 代理(7897)；
# NO_PROXY 必须排除本地回环，否则 TUI 与本地服务器的通信会被代理。
# 只有命令行参数里指定了 muse 模型时才走代理；TUI 里想选 muse 用 `omus`。
omos() {
  local use_proxy=0
  local arg
  for arg in "$@"; do
    if [[ "$arg" == *muse* ]]; then
      use_proxy=1
      break
    fi
  done

  if (( use_proxy )); then
    local -x HTTPS_PROXY=http://127.0.0.1:7897 HTTP_PROXY=http://127.0.0.1:7897 NO_PROXY=localhost,127.0.0.1,::1
  fi

  # opencode v2 起顶层命令不再接受 --port（端口只在 `opencode serve --port` 上配）；
  # TUI 改连后台 service，多开天然支持，不再需要每次随机端口。
  command opencode "$@"
}

# TUI 里想选 muse 系列时用这个入口（始终走代理）
omus() {
  local -x HTTPS_PROXY=http://127.0.0.1:7897 HTTP_PROXY=http://127.0.0.1:7897 NO_PROXY=localhost,127.0.0.1,::1
  omos "$@"
}
