# 使用oh-my-zsh管理插件
#-------------------------------------------------------------
ZSH_CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh
[ ! -d $ZSH_CACHE_DIR ] && mkdir -p $ZSH_CACHE_DIR

# 安装在用户目录下时
ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"
plugins=( z git zsh-completions zsh-autosuggestions zsh-syntax-highlighting fzf-tab )
ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH/oh-my-zsh.sh

# 使用包管理器时
# ZSH=/usr/share/oh-my-zsh
# ZSH_CUSTOM=/usr/share/zsh/
# source /usr/share/oh-my-zsh/oh-my-zsh.sh
# plugins=( z git )
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh
# source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme


# powerlevel10k
#-------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# 自定义 widget：清屏 + 清空滚动缓冲区（保留命令历史, 但输出永久消失）
clear-screen-and-scrollback() {
  # 1. 清可见屏 + 清滚动区（核心）
  printf '\e[H\e[2J\e[3J'
  # 2. 重绘提示符（避免光标/提示符错位）
  zle .reset-prompt
  zle -R
}

# 注册 widget
zle -N clear-screen-and-scrollback

# 绑定到 Ctrl+L（覆盖默认）
bindkey '^L' clear-screen-and-scrollback


# ---------- 自定义可加载的脚本 ----------
find $HOME/.local/shell/env -mindepth 1 | while read line; do source "$line"; done
find $HOME/.local/shell/rc -mindepth 1 | while read line; do source "$line"; done
