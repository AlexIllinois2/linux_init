#!/usr/bin/env bash

# 引入通用脚本
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_base.sh"

# 设置错误处理
set -euo pipefail

info "============================================="
info " Rust 一键安装（清华镜像加速）"
info "============================================="

# 检查sudo
check_sudo

# 1. 安装编译依赖
info "安装开发工具链..."
install curl git

if is_fedora; then
    group_install development-tools
    install openssl-devel
elif is_deb; then
    install build-essential libssl-dev
fi

# 2. 安装 rustup
# 设置 rustup 国内镜像
info "配置清华 rustup 镜像..."
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"

# 安装 rustup（自动确认）
info "安装 rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 3. 配置 cargo 清华镜像
info "配置 cargo 国内源..."
# 复制cargo配置文件
copy ".cargo/config.toml"

# 4. 配置环境变量
info "配置 Rust/Cargo 环境变量..."
copy ".local/shell/env/rust.sh"

# 5. 验证版本
info "============================================="
success "安装完成！当前版本："
source $HOME_DIR/.local/shell/env/rust.sh
rustc --version
cargo --version
rustup --version
info "测试：cargo new hello && cd hello && cargo run"
info "============================================="

