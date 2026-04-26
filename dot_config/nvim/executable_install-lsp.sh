#!/bin/bash

# 自动安装 LSP 服务器的脚本
echo "🔧 正在安装 LSP 服务器..."

nvim -N -u ~/.config/nvim/init.lua \
  --headless \
  -c "MasonInstall gopls lua_ls" \
  -c "sleep 2" \
  -c "Mason" \
  -c "sleep 2000m" \
  -c "q" 2>&1 &

# 等待一下，然后允许用户交互
sleep 3

# 显示说明
echo "✅ Mason 已打开交互界面"
echo "📋 如果上面没有自动安装，请手动按以下步骤操作："
echo "  1. 找到 gopls 并按 'i' 安装"
echo "  2. 找到 lua_ls 并按 'i' 安装"
echo "  3. 按 'q' 退出"

wait
