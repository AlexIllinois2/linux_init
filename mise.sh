#!/usr/bin/env bash

# 引入通用脚本
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_base.sh"

# 设置错误处理
set -euo pipefail

info "============================================="
info " mise 一键安装"
info "============================================="

# 检查sudo
check_sudo

curl https://mise.jdx.dev/install.sh | sh

copy ".local/shell/rc/mise.sh"



