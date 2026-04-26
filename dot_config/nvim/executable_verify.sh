#!/bin/bash

echo "🔍 Neovim 配置验证"
echo "==================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

echo "📦 必需工具："
check_command "nvim"
check_command "stylua"
check_command "gofumpt"
check_command "fd"
check_command "rg"

echo ""
echo "📁 配置文件："
check_file "$HOME/.config/nvim/init.lua"
check_file "$HOME/.config/nvim/lua/options.lua"
check_file "$HOME/.config/nvim/lua/keymaps.lua"
check_file "$HOME/.config/nvim/lua/lazy-bootstrap.lua"

echo ""
echo "🔌 插件目录："
check_dir "$HOME/.local/share/nvim/lazy"
PLUGIN_COUNT=$(ls ~/.local/share/nvim/lazy/ 2>/dev/null | wc -l)
echo -e "${GREEN}✓${NC} 已安装 $PLUGIN_COUNT 个插件"

echo ""
echo "📝 文档文件："
check_file "$HOME/.config/nvim/NVIM_CONFIG.md"
check_file "$HOME/.config/nvim/QUICK_REFERENCE.md"

echo ""
echo "🎯 Shell 别名："
if grep -q "alias v='nvim'" ~/.zshrc; then
    echo -e "${GREEN}✓${NC} v 别名已配置"
else
    echo -e "${RED}✗${NC} v 别名未配置"
fi

echo ""
echo "✨ 验证完成！"
echo ""
echo "下一步操作："
echo "  1. 运行 'nvim' 进行首次初始化"
echo "  2. 在 Neovim 中执行 ':Mason' 安装 LSP"
echo "  3. 搜索 'gopls' 和 'lua_ls' 按 'i' 安装"
