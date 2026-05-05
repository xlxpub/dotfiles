# Neovim 安装与环境准备（macOS）

> 目标：在 macOS 上安装 Neovim 及其依赖，为后续 IDE 配置做好准备。

---

## 1. 安装 Neovim

```bash
brew install neovim
```

验证：

```bash
nvim --version
# 确保版本 >= 0.9（推荐 0.10+）
```

---

## 2. 安装依赖工具

| 工具 | 用途 | 是否必须 |
|------|------|----------|
| `ripgrep` | Telescope 全文搜索 | ✅ 必须 |
| `fd` | Telescope 文件查找 | ✅ 必须 |
| `lazygit` | 终端 Git TUI | 可选 |
| `node` + `npm` | LSP/工具链依赖 | ✅ 必须 |
| `Nerd Font` | 图标字体 | 强烈推荐 |

```bash
# 必装
brew install ripgrep fd

# 可选
brew install lazygit

# 验证 node（已有则跳过）
node --version
npm --version
```

---

## 3. 安装 Nerd Font（推荐）

Nerd Font 提供文件树、状态栏的图标支持。

```bash
# 通过 Homebrew Cask 安装（推荐 JetBrainsMono 或 FiraCode）
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

安装完成后，在终端（iTerm2 / Warp / Terminal.app）中将字体改为 `JetBrainsMono Nerd Font`。

```text
  关于 ?? 图标问题：

  需要在终端配置 Nerd Font 才能正常显示图标。macOS 上用 iTerm2 的话：

  # 1. 下载 Nerd Font（推荐 JetBrainsMono）
  brew install --cask font-jetbrains-mono-nerd-font

  # 2. iTerm2 → Preferences → Profiles → Text
  #    → Font → 选择 "JetBrainsMono Nerd Font"

  配置好后 ?? 就会变成正常的文件图标 🗂️。
```

---

## 4. 配置目录结构

Neovim 配置位于 `~/.config/nvim/`，本教程使用以下模块化结构：

```
~/.config/nvim/
├── init.lua                  # 入口文件，加载各模块
└── lua/
    ├── options.lua           # 基础选项（行号、缩进、剪贴板等）
    ├── keymaps.lua           # 自定义键位映射
    ├── lazy-bootstrap.lua    # 插件管理器 lazy.nvim 初始化
    └── plugins/
        ├── ui.lua            # 主题、状态栏、文件树、标签页
        ├── editor.lua        # 编辑增强（注释、自动括号、git）
        ├── telescope.lua     # 模糊搜索
        ├── treesitter.lua    # 语法高亮
        └── lsp.lua           # LSP + 代码补全 + 格式化
```

创建目录：

```bash
mkdir -p ~/.config/nvim/lua/plugins
```

---

## 5. 快速检查清单

```bash
# 全部通过后进入下一步
nvim --version        # >= 0.9
rg --version          # ripgrep
fd --version          # fd
node --version        # Node.js
npm --version         # npm
go version            # Go
python3 --version     # Python
```

---

> ✅ 环境准备完成，下一步：[neovim-config.md](./neovim-config.md) — 配置插件管理器与核心插件
