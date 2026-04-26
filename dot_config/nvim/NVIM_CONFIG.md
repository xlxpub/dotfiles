# 🚀 Neovim 配置完成指南

## 📋 配置概览

你的 Neovim 配置已经完成！这是一个为 Go 开发优化的现代编辑器配置，同时也支持其他多种编程语言。

### 核心特性
- **主题**：TokyoNight（深色、护眼）
- **插件管理**：Lazy.nvim（快速、现代的插件管理器）
- **LSP 支持**：gopls（Go）、lua_ls（Lua）
- **代码补全**：nvim-cmp（支持 LSP、Snippet）
- **模糊搜索**：Telescope（文件、文本、符号）
- **语法高亮**：TreeSitter（支持 40+ 编程语言）
- **代码格式化**：conform.nvim（保存时自动）

## ⚙️ 已完成的工作

✅ **已安装**：
- Neovim v0.12.1
- stylua（Lua 格式化）
- gofumpt（Go 格式化）
- 38 个 Lazy 插件
- TreeSitter 语言包（Go、Lua、Python、JavaScript 等）

## 🎯 接下来需要完成

### 1️⃣ 首次启动 Neovim
```bash
nvim
```
这会自动完成最后的初始化。

### 2️⃣ 安装 LSP 服务器
在 Neovim 中打开 Mason：
```vim
:Mason
```

然后搜索并安装：
- `gopls` - Go 语言服务器（按 `i` 安装）
- `lua_ls` - Lua 语言服务器（按 `i` 安装）

**或者自动安装**（需要按 `i` 确认）：
```bash
nvim -u ~/.config/nvim/init.lua -N \
  --headless -c "MasonInstall gopls lua_ls" -c "qa"
```

### 3️⃣ 验证功能（可选）
创建一个测试文件验证功能：
```bash
# 创建测试文件
echo 'package main\n\nfunc main() {\n}' > test.go

# 打开并测试
nvim test.go
```

测试项目：
- **`<Space>e`**：打开文件树
- **`<Space>ff`**：查找文件
- **`<Space>fg`**：全文搜索
- **`gd`**：跳转到定义（需要将光标放在变量上）
- **`K`**：查看文档

## 🎮 快速键盘快捷键

### 基础操作
| 快捷键 | 功能 |
|--------|------|
| `<Space>w` | 保存文件 |
| `<Space>q` | 退出 |
| `<Space>Q` | 强制退出全部 |
| `<Esc>` | 清除搜索高亮 |

### 窗口切换
| 快捷键 | 功能 |
|--------|------|
| `<Ctrl>h/j/k/l` | 切换到左/下/上/右窗口 |
| `<Ctrl>上/下/左/右` | 调整窗口大小 |
| `<Shift>h/l` | 切换到上一个/下一个 Buffer |

### 文件和搜索
| 快捷键 | 功能 |
|--------|------|
| `<Space>e` | 文件树开关 |
| `<Space>E` | 文件树定位当前文件 |
| `<Space>ff` | 查找文件 |
| `<Space>fg` | 全文搜索 |
| `<Space>fb` | 搜索 Buffer |
| `<Space>fr` | 最近文件 |

### LSP 功能
| 快捷键 | 功能 |
|--------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gi` | 跳转到实现 |
| `gr` | 查看引用 |
| `K` | 悬浮文档 |
| `<Space>rn` | 重命名 |
| `<Space>ca` | Code Action |
| `[d` / `]d` | 上一个/下一个诊断 |

### Git 集成
| 快捷键 | 功能 |
|--------|------|
| `]h` / `[h` | 下一个/上一个 Git 变更 |
| `<Space>hs` | 暂存变更块 |
| `<Space>hr` | 重置变更块 |
| `<Space>hp` | 预览变更块 |
| `<Space>hb` | 查看行 blame |

### 编辑功能
| 快捷键 | 功能 |
|--------|------|
| `gcc` | 注释当前行 |
| `gbc` | 注释当前块 |
| `ys` | 给文本加括号（例：`ysiw"` 给单词加引号） |
| `cs` | 修改括号（例：`cs"'` 将双引号改为单引号） |
| `ds` | 删除括号（例：`ds"` 删除双引号） |
| `s` / `S` | Flash 快速跳转 |

### Yank 历史
| 快捷键 | 功能 |
|--------|------|
| `p` / `P` | 粘贴（自动记录历史） |
| `<Ctrl>p` / `<Ctrl>n` | 循环切换粘贴历史 |
| `<Space>y` | 打开 Yank 历史面板 |

### 符号和诊断
| 快捷键 | 功能 |
|--------|------|
| `<Space>a` | 符号大纲开关 |
| `[a` / `]a` | 上一个/下一个符号 |
| `<Space>fs` | 当前文件符号搜索 |
| `<Space>fS` | 工作区符号搜索 |
| `<Space>xx` | Trouble 诊断面板 |
| `<Space>xw` | 工作区诊断 |
| `<Space>xd` | 当前文件诊断 |

## 📁 配置文件结构

```
~/.config/nvim/
├── init.lua                    # 入口文件
├── lazy-lock.json              # 插件锁定版本
├── lua/
│   ├── options.lua             # 编辑器选项
│   ├── keymaps.lua             # 按键绑定
│   ├── lazy-bootstrap.lua      # Lazy 启动器
│   └── plugins/
│       ├── lsp.lua             # LSP 配置
│       ├── telescope.lua       # 模糊搜索
│       ├── treesitter.lua      # 语法高亮
│       ├── ui.lua              # UI 组件
│       └── editor.lua          # 编辑功能
└── install-lsp.sh              # LSP 安装脚本
```

## 📦 已安装的主要插件

### UI/主题
- **tokyonight.nvim** - 深色主题
- **lualine.nvim** - 状态栏
- **nvim-tree.lua** - 文件树
- **bufferline.nvim** - 标签页
- **alpha-nvim** - 启动屏幕

### LSP & 补全
- **nvim-lspconfig** - LSP 配置
- **mason.nvim** - LSP/工具管理
- **nvim-cmp** - 代码补全
- **aerial.nvim** - 符号大纲 + winbar 面包屑（取代 lspsaga 的 symbol_in_winbar）

### 编辑工具
- **nvim-treesitter** - 语法高亮
- **conform.nvim** - 代码格式化
- **nvim-surround** - 括号操作
- **nvim-autopairs** - 自动括号配对
- **comment.nvim** - 注释管理

### 搜索和导航
- **telescope.nvim** - 模糊搜索
- **flash.nvim** - 快速跳转
- **gitsigns.nvim** - Git 集成
- **aerial.nvim** - 符号大纲
- **trouble.nvim** - 诊断面板

### 增强功能
- **yanky.nvim** - Yank 历史
- **which-key.nvim** - 按键提示
- **vim-illuminate** - 单词高亮
- **nvim-colorizer.lua** - 颜色预览
- **indent-blankline.nvim** - 缩进指南

## 🔧 常见问题

### Q: 如何添加新的编程语言支持？
A: 编辑 `lua/plugins/treesitter.lua`，将语言添加到 `ensure_installed` 列表。

### Q: 如何添加新的 LSP 服务器？
A: 编辑 `lua/plugins/lsp.lua`，在 `ensure_installed` 中添加服务器名称。

### Q: 如何修改快捷键？
A: 编辑 `lua/keymaps.lua`，修改相应的 `map()` 调用。

### Q: 如何关闭某个功能？
A: 编辑 `lua/plugins/*.lua` 中的相应配置，或从插件列表中删除。

### Q: 如何配置其他编程语言（Python、JavaScript 等）？
A: 
1. 在 `treesitter.lua` 的 `ensure_installed` 中添加语言
2. 在 `lsp.lua` 的 `ensure_installed` 中添加对应的 LSP 服务器（例如 `pyright`、`ts_ls`）
3. 在 `:Mason` 中安装相应的格式化工具

## 🚀 优化建议

### 1. 添加更多语言支持
如果你需要使用其他编程语言，编辑 `lua/plugins/treesitter.lua` 和 `lua/plugins/lsp.lua`。

### 2. 配置 Shell 别名（可选）
在 `~/.zshrc` 或 `~/.bashrc` 中添加：
```bash
alias v='nvim'
alias vi='nvim'
```

### 3. 性能调优
- 禁用不需要的插件（在 `lua/plugins/*.lua` 中注释掉）
- 调整 `updatetime` 值（默认 250ms）

## 📚 学习资源

- Neovim 官网：https://neovim.io/
- Lua 教程：https://www.lua.org/pil/
- Which-key 帮助：在 Neovim 中按 `<Space>` 会显示帮助

## ✨ 下一步

1. **首次启动**：`nvim` 打开编辑器
2. **安装 LSP**：在 Mason 中安装 gopls 和 lua_ls
3. **开始编辑**：尝试打开一个 Go 或 Lua 文件
4. **自定义**：根据你的需要调整配置

祝你使用愉快！🎉
