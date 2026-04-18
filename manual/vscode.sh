#!/usr/bin/env bash

# 可以帮我写一个linux上安装vscode 的.tar.gz到用户目录的脚本吗? 包括桌面启动图标, 命令行命令(软连接到$HOME/.local/bin),程序安装在$HOME/.local/app/vscode,脚本执行后提示用户输入压缩包查找目录,然后自动找vscode的压缩包安装(不限定版本,如果有多个就用最新的)

set -e

INSTALL_DIR="$HOME/.local/app/vscode"
BIN_DIR="$HOME/.local/bin"
DESKTOP_FILE="$HOME/.local/share/applications/vscode.desktop"

echo "请输入要搜索 VSCode 压缩包的目录："
read -r SEARCH_DIR

if [ ! -d "$SEARCH_DIR" ]; then
    echo "❌ 目录不存在: $SEARCH_DIR"
    exit 1
fi

echo "🔍 正在查找 VSCode .tar.gz 压缩包..."

# 查找 vscode tar.gz，按修改时间排序，取最新
VSCODE_TAR=$(find "$SEARCH_DIR" -type f -name "code-*.tar.gz" -o -name "vscode-*.tar.gz" 2>/dev/null | sort -r | head -n 1)

if [ -z "$VSCODE_TAR" ]; then
    echo "❌ 未找到 VSCode 压缩包"
    exit 1
fi

echo "✅ 找到压缩包: $VSCODE_TAR"

# 创建目录
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$(dirname "$DESKTOP_FILE")"

echo "📦 正在解压..."

# 清空旧版本
rm -rf "$INSTALL_DIR"/*

tar -xzf "$VSCODE_TAR" -C "$INSTALL_DIR" --strip-components=1

# 查找可执行文件
CODE_BIN=$(find "$INSTALL_DIR" -type f -name "code" | head -n 1)

if [ ! -f "$CODE_BIN" ]; then
    echo "❌ 未找到 code 可执行文件"
    exit 1
fi

echo "🔗 创建命令行快捷方式..."

ln -sf "$CODE_BIN" "$BIN_DIR/code"

# 检查 PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "⚠️ 请将 $BIN_DIR 加入 PATH，例如："
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

echo "🖥️ 创建桌面启动图标..."

ICON_PATH="$INSTALL_DIR/resources/app/resources/linux/code.png"

# 有些版本图标路径不同，兜底查找
if [ ! -f "$ICON_PATH" ]; then
    ICON_PATH=$(find "$INSTALL_DIR" -name "code.png" | head -n 1)
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
Exec=$CODE_BIN
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

echo ""
echo "🎉 安装完成！"
echo ""
echo "👉 启动方式："
echo "1. 终端输入: code"
echo "2. 桌面环境中搜索: Visual Studio Code"
echo ""
