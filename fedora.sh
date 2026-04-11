#!/usr/bin/env bash

# 如果备份已存在则不再执行
if [ -f "/etc/yum.repos.d/fedora.repo.bak" ]; then
    info "源文件已存在备份，跳过执行换源"
    exit 0
fi

sudo cp /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.bak
sudo cp /etc/yum.repos.d/fedora-updates.repo /etc/yum.repos.d/fedora-updates.repo.bak

# 切换到清华源
sudo sed -e 's|^metalink=|#metalink=|g' \
-e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora|g' \
-i.bak \
/etc/yum.repos.d/fedora.repo \
/etc/yum.repos.d/fedora-updates.repo

# 更新缓存
sudo dnf makecache
# 更新系统
sudo dnf update