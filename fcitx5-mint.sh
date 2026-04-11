#!/usr/bin/env bash

# 引入通用脚本
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_base.sh"

# 设置错误处理
set -euo pipefail

info "========================================"
info " fcitx5+Rime 输入法安装配置"
info " 含：云拼音、薄荷输入法、全软件兼容"
info "========================================"

# 检查sudo
check_sudo

# 1. 清理旧输入法、冲突包
info "清理旧ibus/fcitx残留"
if is_fedora; then
    remove ibus ibus-rime fcitx fcitx-rime || true
elif is_deb; then
    remove ibus ibus-rime fcitx fcitx-rime || true
fi

# 2. 安装输入法包
info "安装 fcitx5 + Rime + 中文插件"
if is_fedora; then
    install \
        fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-autostart \
        fcitx5-rime librime librime-lua \
        fcitx5-chinese-addons
elif is_deb; then
    install \
        fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt \
        fcitx5-rime librime-bin \
        fcitx5-chinese-addons
fi

# 3. 全局环境变量
info "写入输入法全局环境变量（修复所有软件无法输入）"
sudo tee /etc/profile.d/fcitx5-env.sh > /dev/null <<'EOF'
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export INPUT_METHOD=fcitx5
export SDL_IM_MODULE=fcitx5
EOF
sudo chmod +x /etc/profile.d/fcitx5-env.sh

# 4. 修复Flatpak应用中文输入
info "修复Flatpak应用输入"
flatpak override --user --env=GTK_IM_MODULE=fcitx5 2>/dev/null || true
flatpak override --user --env=QT_IM_MODULE=fcitx5  2>/dev/null || true

# 5. 部署薄荷输入法 Oh-My-Rime
info "部署薄荷输入法 Oh-My-Rime"
RIME_DIR="$HOME_DIR/.local/share/fcitx5/rime"
REPO_URL="https://cnb.cool/Mintimate/rime/oh-my-rime"

mkdir_p "$RIME_DIR"
cd "$RIME_DIR"

# 初始化 Git 并强制拉取（解决目录非空问题）
if [ ! -d ".git" ]; then
    info "初始化仓库并拉取 薄荷输入法（仅最新版）"
    git init
    git remote add origin "$REPO_URL"
    git fetch --depth 1
    git checkout -f main
else
    info "增量更新（仅更新变化文件，不浪费硬盘）"
    git fetch --depth 1
    git reset --hard origin/main
fi

# 配置默认输入法列表和云拼音
info "配置默认输入法列表和云拼音"
# 复制RIME配置文件
copy ".local/share/fcitx5/rime/default.custom.yaml"
copy ".local/share/fcitx5/rime/cloud_pinyin.schema.yaml"
copy ".config/fcitx5/conf/rime.conf"

# 6. 创建快捷命令
info "创建快捷命令"
# 复制快捷命令脚本
copy ".local/bin/mint-rime-update"
copy ".local/bin/mint-rime-deploy"

# 设置执行权限
chmod +x $HOME_DIR/.local/bin/mint-rime-update
chmod +x $HOME_DIR/.local/bin/mint-rime-deploy

# 7. 重启fcitx5、部署Rime
info "重启输入法、部署Rime"
killall fcitx5 2>/dev/null || true
fcitx5 -d &
sleep 2

info "========================================"
success "安装配置完成！"
info "⚠️ 必须：注销当前用户 → 重新登录"
info "登录后：右上角键盘 → 配置 → 添加 → 汉语 → Rime"
info "默认输入法：薄荷拼音-全拼"
info "可用方案：薄荷拼音、云拼音"
info "切换方案：Ctrl + \\"
info ""
info "🛠️  更新命令：mint-rime-update"
info "🛠️  部署命令：mint-rime-deploy"
info "========================================"
