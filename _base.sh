#!/usr/bin/env bash

# git信息 记得修改
NAME="$(whoami)"
EMAIL="$(whoami)"

# 常用环境变量
export DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HOME_DIR="$HOME"
export GITHUB_PROXY=''
export PLUGIN_FROM_MIRROR=2

# 创建必要的目录
mkdir -p $HOME_DIR/.local/shell/{env,rc}
mkdir -p $HOME_DIR/.local/{bin,script,appimage,lib}

# 系统判断
ID="$([ -f /etc/os-release ] && cat /etc/os-release | grep ^ID= || echo 'ID=termux')"
eval "$ID"

is_ubuntu() {
    [ "$ID" = "ubuntu" ]
}

is_debian() {
    [ "$ID" = "debian" ]
}

is_deb() {
    is_ubuntu || is_debian
}

is_fedora() {
    [ "$ID" = "fedora" ]
}

is_termux() {
    [ "$ID" = "termux" ]
}

# 系统安装命令包装
install() {
    echo "安装程序包: $@"
    if is_deb; then
        sudo apt install -y "$@" 
    elif is_fedora; then
        sudo dnf install -y "$@" 
    elif is_termux; then
        pkg install -y "$@"
    fi
}

# 系统组安装命令包装
group_install() {
    echo "安装软件组: $@"
    if is_deb; then
        sudo apt install -y "$@" 
    elif is_fedora; then
        sudo dnf group install -y "$@" 
    fi
}

# 系统移除命令包装
remove() {
    echo "移除程序包: $@"
    if is_deb; then
        sudo apt remove -y "$@" 
    elif is_fedora; then
        sudo dnf remove -y "$@" 
    elif is_termux; then
        pkg remove -y "$@"
    fi
}

# 系统更新命令包装
update() {
    echo "更新系统包索引"
    if is_deb; then
        sudo apt update
    elif is_fedora; then
        sudo dnf makecache
    elif is_termux; then
        pkg update    
    fi
}

# 系统升级命令包装
upgrade() {
    echo "升级系统包"
    if is_deb; then
        sudo apt full-upgrade -y
    elif is_fedora; then
        sudo dnf upgrade -y
    elif is_termux; then
        pkg upgrade -y    
    fi
}

# 自动移除命令包装
autoremove() {
    echo "自动移除无用包"
    if is_deb; then
        sudo apt autoremove -y
    elif is_fedora; then
        sudo dnf autoremove -y
    elif is_termux; then
        pkg autoremove -y    
    fi
}

# 搜索命令包装
search() {
    echo "搜索程序包: $@"
    if is_deb; then
        apt search "$@"
    elif is_fedora; then
        dnf search "$@"
    elif is_termux; then
        pkg search "$@"
    fi
}

# 清理缓存命令包装
clean() {
    echo "清理缓存"
    if is_deb; then
        sudo apt clean
    elif is_fedora; then
        sudo dnf clean all
    elif is_termux; then
        pkg clean    
    fi
}

# 检查sudo是否可用
check_sudo() {
    if ! is_termux && ! command -v sudo &> /dev/null; then
        echo "错误: 未找到 sudo 命令，请先安装 sudo！"
        exit 1
    fi
}

# 获取git仓库地址（支持镜像）
get_git_repo() {
    local repo="$1"
    local mirror="$2"
    
    if [ "$PLUGIN_FROM_MIRROR" -eq 2 ]; then
        # gitcode镜像
        echo "https://gitcode.com/gh_mirrors/${repo#https://github.com/}"
    elif [ "$PLUGIN_FROM_MIRROR" -eq 1 ]; then
        # gitee镜像
        local repo_name=$(basename "$repo")
        echo "https://gitee.com/mirrors/${repo_name%.git}"
    else
        # 原始github地址（可选代理）
        echo "${GITHUB_PROXY}${repo}"
    fi
}

# 克隆git仓库
git_clone() {
    local repo="$1"
    local dest="$2"
    
    if [ -z "$dest" ]; then
        dest="${repo##*/}"
        dest="${dest%.git}"
    fi
    
    local repo_url=$(get_git_repo "$repo")
    echo "克隆仓库: $repo_url -> $dest"
    git clone --depth=1 "$repo_url" "$dest"
}

# 设置文件权限
set_permissions() {
    local file="$1"
    local mode="$2"
    chmod "$mode" "$file"
}

# 创建目录（如果不存在）
mkdir_p() {
    mkdir -p "$@"
}

# 打印信息
info() {
    echo "信息: $@"
}

# 打印错误
error() {
    echo "错误: $@" >&2
}

# 打印成功
success() {
    echo "成功: $@"
}

# 等待用户确认
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 获取当前用户
get_user() {
    whoami
}

# 获取当前目录
get_pwd() {
    pwd
}

# 同步包索引
sync_packages() {
    update
}



# 下载文件（支持断点续传）
download() {
    local url="$1"
    local output="$2"
    
    if [ -z "$output" ]; then
        output="${url##*/}"
    fi
    
    if [ -f "$output" ]; then
        info "文件已存在，跳过下载: $output"
        return 0
    fi
    
    info "下载文件: $url -> $output"
    wget --continue -O "$output" "$url"
}

# 克隆或更新git仓库
git_clone_or_update() {
    local repo="$1"
    local dest="$2"
    
    if [ -z "$dest" ]; then
        dest="${repo##*/}"
        dest="${dest%.git}"
    fi
    
    if [ -d "$dest/.git" ]; then
        info "更新仓库: $dest"
        cd "$dest"
        git pull --depth=1
        cd - > /dev/null
    else
        git_clone "$repo" "$dest"
    fi
}

# 创建备份目录
create_backup_dir() {
    mkdir_p "$DIR_PATH/backup/home"
    mkdir_p "$DIR_PATH/backup/root"
}

# 复制用户配置文件/目录
copy() {
    local src_path="$1"
    local src_full="$DIR_PATH/config/home/$src_path"
    local dest_full="$HOME_DIR/$src_path"
    
    if [ ! -e "$src_full" ]; then
        error "源文件/目录不存在: $src_full"
        return 1
    fi
    
    # 创建目标目录
    mkdir_p "$(dirname "$dest_full")"
    
    # 复制文件/目录（直接覆盖）
    info "复制文件/目录: $src_full -> $dest_full"
    cp -r "$src_full" "$dest_full"
    
    success "复制完成: $src_path"
}

# 复制系统配置文件/目录（需要sudo）
copy_root() {
    local src_path="$1"
    local src_full="$DIR_PATH/config/root/$src_path"
    local dest_full="/$src_path"
    
    if [ ! -e "$src_full" ]; then
        error "源文件/目录不存在: $src_full"
        return 1
    fi
    
    # 创建目标目录
    sudo mkdir -p "$(dirname "$dest_full")"
    
    # 复制文件/目录（直接覆盖）
    info "复制文件/目录: $src_full -> $dest_full"
    sudo cp -r "$src_full" "$dest_full"
    
    success "复制完成: $src_path"
}
