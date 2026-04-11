#!/usr/bin/env bash

# 引入通用脚本
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_base.sh"

# 设置错误处理
set -euo pipefail

# git邮箱, 记得修改为自己的邮箱
EMAIL="$(whoami)"

# 检查sudo
check_sudo

# 同步包索引
sync_packages


init_ssh() {
  if [ -f "$HOME_DIR/.ssh/id_rsa" ]; then
      chmod 700 $HOME_DIR/.ssh
      chmod 644 $HOME_DIR/.ssh/id_rsa.pub
      chmod 600 $HOME_DIR/.ssh/id_rsa
      # wsl需要
      eval $(ssh-agent)
      ssh-add $HOME_DIR/.ssh/id_rsa
      success 'ssh密钥已添加'
  fi
}
init_ssh


init_git() {
  install git
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL" 
  git config --global init.defaultBranch main
  git config --global push.default current 
  git config --global pull.rebase false
  git config --global advice.addIgnoredFile false
  
  # 复制SSH配置文件
  copy ".ssh/config"
  
  success 'git初始化完成'
}
init_git


init_zsh() {
  install eza
  is_termux && install fd || install fd-find
  install zsh fzf bat vim

  # 安装插件
  git_clone_or_update "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME_DIR/.oh-my-zsh"
  git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  
  # zsh-completions 特殊处理
  local zsh_completions_dir="${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}/plugins/zsh-completions"
  if [ ! -d "$zsh_completions_dir/.git" ]; then
      if [ $PLUGIN_FROM_MIRROR -eq 2 ] || [ $PLUGIN_FROM_MIRROR -eq 1 ]; then
          git clone --depth=1 https://gitee.com/duchenpaul/zsh-completions.git "$zsh_completions_dir"
      else
          git_clone "https://github.com/zsh-users/zsh-completions.git" "$zsh_completions_dir"
      fi
  fi
  
  git_clone_or_update "https://github.com/Aloxaf/fzf-tab.git" "${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}/plugins/fzf-tab"
  git_clone_or_update "https://github.com/romkatv/powerlevel10k.git" "${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}/themes/powerlevel10k"
  
  success 'zsh插件已安装'

  # 复制.zshrc配置文件
  copy ".zshrc"
  success 'zsh配置完成'

  # 复制git命令别名
  copy ".local/shell/rc/git.zsh"
  success 'git别名已安装'
  
  info "修改默认shell为zsh"
  is_termux && chsh -s zsh || chsh -s "$(which zsh)"
}
init_zsh


init_shell() {
  # 复制配置文件到用户目录
  copy ".local/shell/env/path.sh"
  copy ".local/shell/rc/base.sh"
  
  if is_deb; then
      copy ".local/shell/rc/apt.sh"
  elif is_fedora; then
      copy ".local/shell/rc/dnf.sh"
  fi
}
init_shell


init_scripts() {
  # 复制脚本文件
  copy ".local/script/k"
  copy ".local/script/len"
  
  # 设置执行权限
  chmod +x $HOME_DIR/.local/script/*
  
  success '脚本已安装'
}
init_scripts
