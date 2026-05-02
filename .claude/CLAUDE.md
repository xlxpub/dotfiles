# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个 chezmoi 管理的 dotfiles 仓库，支持两台 Mac（Intel x86_64 和 Apple Silicon arm64）。用户是 zsh/nvim 中度使用者。

## 常用命令

```bash
# 应用变更到目标路径（~/.zshrc、~/.config/nvim/ 等）
chezmoi apply

# 预览差异（不实际写入）
chezmoi diff

# 编辑某个目标文件（会自动打开 source 文件）
chezmoi edit ~/.zshrc

# 添加新文件纳入管理
chezmoi add ~/.config/xxx

# 查看模板渲染结果（调试 .tmpl 文件）
chezmoi execute-template < dot_zshrc.tmpl
```

## 架构与命名规则

### chezmoi 文件映射

| 源文件前缀 | 目标路径 |
|---|---|
| `dot_` | `.`（如 `dot_zshrc.tmpl` → `~/.zshrc`） |
| `dot_config/` | `~/.config/` |
| `executable_` | 文件带 +x 权限 |
| `.tmpl` 后缀 | Go 模板文件，渲染时使用 chezmoi 数据 |

### 多架构模板

`.tmpl` 文件通过 `{{ if eq .chezmoi.arch "arm64" }}` 区分架构，主要差异：
- Homebrew 路径：arm64 用 `/opt/homebrew/`，Intel 用 `/usr/local/`
- Go/JDK 安装路径不同
- MySQL 路径不同

### Neovim 配置结构（`dot_config/nvim/`）

加载顺序：`init.lua` → `options.lua` → `keymaps.lua` → `lazy-bootstrap.lua` → `lua/plugins/*.lua`

- 插件管理器：lazy.nvim（自动 bootstrap）
- LSP：mason + nvim-lspconfig，已配置 gopls、lua_ls
- 补全：nvim-cmp + LuaSnip
- 格式化：conform.nvim（手动触发 `<leader>lf`，不自动保存格式化）
- 文件搜索：Telescope
- UI：snacks.nvim

### 主要工具链

zsh 插件（手动安装在 `~/.local/share/zsh/plugins/`）：
- zsh-autosuggestions、zsh-syntax-highlighting、zsh-completions、git plugin

命令行工具依赖：starship（提示符）、zoxide（目录跳转）、fzf（模糊搜索）、lsd（ls 替代）、lazygit、bat

## 规则

1. 每次变更都要追加到 README.md
2. `~/.env` 存放敏感环境变量，**不提交 git**
3. 模板文件修改后需在两种架构下验证逻辑（用 `chezmoi execute-template` 检查）
4. nvim 插件锁定文件 `lazy-lock.json` 纳入版本管理以保持两台机器一致
5. 所有nvim快捷键都放到 dot_config/nvim/keymap.md,在新增、修改时要同步更新
