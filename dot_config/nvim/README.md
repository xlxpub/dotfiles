这是 macOS 上 Neovim 的配置文件，存放目录：`~/.config/nvim`

在一台新电脑上安装时，直接告诉 Claude：`该目录是 neovim 的配置目录，请你帮我完成一些配置、安装，方便我在这台电脑上使用 nvim`

---

## 📁 目录结构

```
~/.config/nvim/
├── init.lua                    # 入口（屏蔽 deprecated 告警）
├── lua/
│   ├── options.lua             # 基础选项、Go 环境注入、外部修改自动重载
│   ├── keymaps.lua             # 全局快捷键
│   ├── lazy-bootstrap.lua      # lazy.nvim 自动安装
│   ├── plugins/
│   │   ├── snacks.lua          # snacks.nvim（终端）
│   │   ├── ui.lua              # 主题、lualine、diff 高亮、aerial winbar
│   │   ├── lsp.lua             # LSP、conform 格式化、aerial
│   │   ├── telescope.lua       # 模糊搜索
│   │   ├── editor.lua          # diffview、markdown-preview、which-key 等
│   │   └── treesitter.lua      # treesitter
│   └── tools/
│       └── json_md_preview.lua # JSON 内嵌字段提取预览工具
```

---

## ⌨️ 快捷键速查

> Leader 键 = `Space`

### 文件 / 窗口

| 按键 | 功能 |
|------|------|
| `<leader>w` | 保存文件 |
| `<leader>q` | 退出 |
| `<leader>Q` | 强制退出全部 |
| `<leader>e` | 文件树开关 / 检查重载外部修改 |
| `<leader>E` | 文件树定位当前文件 / 强制重载 |
| `<S-h>` / `<S-l>` | 上 / 下一个 buffer |
| `<C-h/j/k/l>` | 切换窗口 |
| `<C-↑↓←→>` | 调整窗口大小 |

### Telescope 搜索

| 按键 | 功能 |
|------|------|
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 全文搜索（live grep） |
| `<leader>fb` | 搜索 buffer |
| `<leader>fr` | 最近文件 |
| `<leader>fh` | 搜索帮助文档 |

> 遵守 `.gitignore`；隐藏文件可见；`.venv` / `node_modules` 等自动排除

### LSP

| 按键 | 功能 |
|------|------|
| `gd` | 跳转到定义 |
| `gr` | 查看引用 |
| `K` | 悬浮文档 |
| `<leader>rn` | 重命名 |
| `<leader>ca` | Code Action |
| `<leader>ci` / `<leader>co` | 调用链：入 / 出 |
| `<leader>lf` | 格式化当前文件（conform.nvim） |

### 复制到剪贴板（`y` 前缀）

| 按键 | 复制内容 | 示例 |
|------|----------|------|
| `<leader>yp` | 相对路径 | `lua/keymaps.lua` |
| `<leader>yP` | 绝对路径 | `/Users/xxx/.config/nvim/lua/keymaps.lua` |
| `<leader>yn` | 仅文件名 | `keymaps.lua` |
| `<leader>yf` | 当前函数名（光标在函数体内任意位置） | `handleSubmit` |

> 结果写入系统剪贴板（`+` 寄存器），可直接 Cmd+V 粘贴

### Git 冲突解决（Diffview，`g` 前缀）

> 使用场景：`git merge` 产生冲突后执行 `<leader>gd`，光标放到**中间**窗口的冲突块里

| 按键 | 功能 |
|------|------|
| `<leader>gd` | 打开 Diffview 合并视图 |
| `<leader>gD` | 关闭 Diffview |
| `<leader>gl` | 选择本地版本 (OURS) |
| `<leader>gR` | 选择远程版本 (THEIRS) |
| `<leader>gB` | 选择共同祖先 (BASE) |
| `<leader>gA` | 保留全部三方 |
| `<leader>gX` | 删除整个冲突块 |
| `<leader>gb` | 放弃修改重载文件（应急） |
| `]x` / `[x` | 跳到下 / 上一个冲突块 |
| `]c` / `[c` | 同一文件内 diff 块跳转 |

### 文本对象跳转（treesitter-textobjects）

| 按键 | 功能 |
|------|------|
| `]f` / `[f` | 跳到下 / 上一个函数开头 |
| `]F` / `[F` | 跳到下 / 上一个函数结尾 |
| `]c` / `[c` | 跳到下 / 上一个 class |

可视 / operator-pending 模式下同样有效（`af`=整个函数、`if`=函数体、`ac/ic`=类、`aa/ia`=参数）。



| 按键 | 功能 |
|------|------|
| `<leader>tt` | 底部分屏终端开关 |
| `<leader>tf` | 浮动终端开关 |

### JSON 工具（`j` 前缀）

| 按键 | 模式 | 功能 |
|------|------|------|
| `<leader>jf` | 普通 | 整个文件格式化（jq） |
| `<leader>jf` | 可视 | 格式化选中区域 |
| `<leader>jm` | 普通 | 压缩为单行 |
| `<leader>jej` | 普通 | 提取光标处 JSON 字符串并格式化预览 |
| `<leader>jem` | 普通 | 提取光标处 Markdown 字段（buffer 预览） |
| `<leader>jeM` | 普通 | 提取光标处 Markdown 字段（浏览器预览） |

### Markdown

| 按键 | 功能 |
|------|------|
| `<leader>mp` | 切换浏览器实时预览 |

---

## 🎨 主题

`github_dark_dimmed`（projekt0n/github-nvim-theme），背景 dark。

diff 高亮：行级淡底色 + 字符级亮蓝加粗；diffview 字符级差异亮绿 / 亮红。

---

## 🔧 代码格式化（conform.nvim，手动触发）

| 文件类型 | 格式化器 |
|---------|---------|
| `.go` | goimports → gofumpt |
| `.lua` | stylua |
| `.json` / `.jsonc` / `.yaml` / `.md` | prettier |
| `.js` / `.ts` / `.jsx` / `.tsx` / `.html` / `.css` | prettier |

---

## 📦 外部依赖（新机器安装核对）

```bash
brew install ripgrep fd stylua node lua-language-server
npm install -g prettier
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
```

| 工具 | 用途 |
|------|------|
| `rg` (ripgrep) | Telescope live_grep |
| `fd` | Telescope find_files |
| `node` / `npm` | markdown-preview + prettier |
| `prettier` | JSON / MD / YAML / 前端格式化 |
| `stylua` | Lua 格式化 |
| `gopls` | Go LSP |
| `gofumpt` / `goimports` | Go 格式化 |
| `lua-language-server` | Lua LSP（可选） |

---

## 📝 变更记录（2026-04）

- 修复 `]f` / `[f` 函数跳转失效：新版 treesitter-textobjects 移除了 `setup()` 中的 keymaps 配置，改为手动 `keymap.set` 调用 `move.goto_next_start` 等函数；新增 `]F` / `[F`（跳函数结尾）
- 新增复制快捷键：相对路径 / 绝对路径 / 文件名 / 函数名（treesitter）
- Telescope 改为遵守 `.gitignore`（移除 `--no-ignore`）
- 移除 lspsaga，改用 nvim 原生 LSP UI；winbar 由 aerial.nvim 提供
- 主题从 `github_light_default` 切换为 `github_dark_dimmed`
- 修复 gopls 报 `identify GOROOT dir cmd failed`
- 新增 JSON 内嵌字段提取预览工具（`<leader>je*`）
- iTerm2 窗口标题显示当前文件名 / 目录
- 屏蔽三方插件 deprecated 告警（`vim.deprecate = function() end`）
- 修复 CursorHold checktime 在命令行窗口（`q:`）中触发 E11 错误：增加 `getcmdwintype()` 判断
