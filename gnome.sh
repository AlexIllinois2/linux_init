#!/usr/bin/env bash

# 引入通用脚本
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_base.sh"

# 设置错误处理
set -euo pipefail

# 检查sudo
check_sudo

# 检查是否为GNOME桌面环境
if ! command_exists gnome-shell; then
    error "未检测到GNOME桌面环境，该脚本仅适用于GNOME桌面"
    exit 1
fi

# 安装核心连接器+扩展管理工具
info "安装GNOME扩展管理工具..."
if is_fedora; then
    install gnome-browser-connector gnome-extensions-app
elif is_deb; then
    install gnome-shell-extension-prefs
fi

info "Firefox：打开附加组件商店，搜索安装 GNOME Shell Integration"
info "Chrome/Edge：Chrome 网上应用店，搜索安装 GNOME Shell Integration"

# 安装GNOME扩展
info "安装GNOME扩展..."
if is_fedora; then
    install \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-user-theme \
        gnome-shell-extension-blur-my-shell
fi

info "推荐手动安装的扩展："
info "- Clipboard Indicator: https://extensions.gnome.org/extension/779/clipboard-indicator/"
info "- Window Is Ready - Notification Remover: https://extensions.gnome.org/extension/1007/window-is-ready-notification-remover/"
info "- Net Speed Plus: https://extensions.gnome.org/extension/9138/net-speed/"

# GSConnect 
info "安装GSConnect（手机连接）..."
if is_fedora; then
    install gnome-shell-extension-gsconnect nautilus-gsconnect
    gnome-extensions enable gsconnect@andyholmes.github.io
    
    # 永久放行kdeconnect服务（默认public区域）
    sudo firewall-cmd --permanent --add-service=kdeconnect
    # 重载防火墙
    sudo firewall-cmd --reload
    # 如果是 FedoraWorkstation 区域：
    #sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-service=kdeconnect
    #sudo firewall-cmd --reload
    
    success "GSConnect已安装并启用"
else
    info "GSConnect在当前系统上暂不支持自动安装，请手动安装"
fi

success "GNOME扩展安装完成"

