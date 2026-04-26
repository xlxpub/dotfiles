这是macos上neovim的配置文件，存放目录：~/.config/nvim

在一台新电脑上安装时，直接告诉claude: `该目录是neovim的配置目录，请你帮我完成一些配置、安装，方便我在这台电脑上使用nvim`

---

## 📝 最近配置变更（2026-04）

### 📄 JSON 中的 Markdown 字段预览
JSON 文件里经常嵌 markdown 字符串（Claude prompts / LLM 配置 / i18n），值含 `\n`、`\t`、`\"` 转义，肉眼看不了。

新增工具：**把光标放到 JSON 字符串字面量上，按快捷键自动反转义并渲染**。

| 按键 | 作用 |
|---|---|
| `<leader>mj` | 提取字段 → 新 buffer 渲染为 markdown（`q` 关闭） |
| `<leader>mJ` | 提取字段 → 新 buffer + 调 `MarkdownPreview` 浏览器预览 |

实现要点（`lua/tools/json_md_preview.lua`）：
- 优先用 **treesitter** 定位光标所在的 `string` 节点（精准，支持跨行字符串）
- 取节点 raw 文本后用 `vim.json.decode` 反转义（`\n` → 真实换行、`\"` → `"`）
- treesitter parser 未就绪时回退到 lua 正则按行匹配 `"key": "value"`
- 渲染目标 buffer：`buftype=nofile` + `filetype=markdown` + `q` 关闭
- 预览窗口自动软换行：`wrap` + `linebreak`（英文单词不切断）+ `breakindent`（续行缩进对齐）+ `showbreak = ↪`（续行提示符），关闭 `number/signcolumn` 腾出宽度
- **复用预览 buffer**：多次调用 `<leader>mj` 不会堆叠窗口，也不会因重名触发 `E95`；`q` 只关窗、不销毁，下次直接重用；每次渲染后光标回顶部

文件：`lua/tools/json_md_preview.lua`、`lua/keymaps.lua`

### 🌙 主题切换为 GitHub Dark Dimmed
- colorscheme：`github_dark_dimmed`（取代原 `github_light_default`）
- lualine theme 同步切换到 `github_dark_dimmed`
- `background = "dark"`
- diff 高亮重新设计：行级背景用暗绿/暗蓝/暗红淡底，字符级 `DiffText` 用 **亮蓝 `#1f6feb` + 纯白粗体** 以保证对比度
- `DiffviewDiffAddText` 亮绿 `#238636` / `DiffviewDiffDeleteText` 亮红 `#da3633`，diffview 左右字符级差异一眼可辨

文件：`lua/plugins/ui.lua`

### 🚫 移除 lspsaga，改用 nvim 原生 LSP UI
**原因**：lspsaga.nvim 跟不上 nvim 0.12 的 API 变更，持续产生 deprecated 告警。

替换映射（按键保持不变）：

| 按键 | 旧（lspsaga） | 新（nvim 原生） |
|---|---|---|
| `K` | `Lspsaga hover_doc` | `vim.lsp.buf.hover` |
| `<leader>rn` | `Lspsaga rename` | `vim.lsp.buf.rename` |
| `<leader>ca` | `Lspsaga code_action` | `vim.lsp.buf.code_action` |
| `<leader>ci` / `<leader>co` | `Lspsaga incoming_calls` / `outgoing_calls` | `vim.lsp.buf.incoming_calls` / `outgoing_calls` |

附加改动：
- monkey-patch `vim.lsp.util.open_floating_preview` 给所有 LSP 浮窗统一加 `rounded` 边框（代替 lspsaga 的 UI 美化；避开 0.12 已弃用的 `vim.lsp.with`）
- winbar 面包屑改由 **aerial.nvim** 提供：`LspAttach` 时注入自定义 `_aerial_winbar()` 函数（基于 `aerial.get_location()`，因新版 aerial 已移除 `fmt_winbar`），开启 `attach_mode = "window"` + `show_guides = true`

文件：`lua/plugins/lsp.lua`、`lua/plugins/ui.lua`

### 🔕 屏蔽三方插件 deprecated 告警
`init.lua` 顶部：

```lua
vim.deprecate = function() end
```

原因：vim-illuminate / trouble.nvim / telescope.nvim / conform.nvim / nvim-lspconfig 内部仍有 `client.supports_method(...)`（点号调用）、`make_position_params(无参)` 等旧 API 调用，在 nvim 0.12 上持续刷屏。覆盖 `vim.deprecate` 即全局静音所有 deprecation 告警。

**副作用**：只静音"即将废弃"类提示，不影响实际功能和运行时错误。需排查 deprecation 问题时注释该行即可恢复。

文件：`init.lua`

### 🔑 which-key 补充 `]c` / `[c` 说明
`]c` / `[c` 在 diff 模式下是 Vim **内置命令**（不是 keymap），which-key 默认不会显示。手动注册说明条目：

| 按键 | 说明 |
|---|---|
| `]c` | 下一个 diff 改动点（diff 模式）/ 下一个 class（普通模式，treesitter-textobjects） |
| `[c` | 上一个 diff 改动点（diff 模式）/ 上一个 class（普通模式） |

仅补充文档说明，不改变实际行为。

文件：`lua/plugins/editor.lua`

---

## 📝 更早变更（2026-04）

### 🎨 主题切换为 GitHub 浅色风格（已被 Dark Dimmed 取代）
- 插件：`projekt0n/github-nvim-theme`
- colorscheme：`github_light_default`
- lualine 同步切换到 `github_light_default`
- 自定义 diff 高亮：GitHub PR 风格（淡绿/淡蓝/淡红 + 字符级鲜绿加粗）

文件：`lua/plugins/ui.lua`

### 🔀 Git 冲突解决（Diffview 集成）
3-way 合并视图 + 自定义键位（通过 `diffview.actions.conflict_choose` API）：

| 按键 | 作用 |
|------|------|
| `<leader>gd` | 打开 Diffview 合并视图 |
| `<leader>gD` | 关闭 Diffview |
| `<leader>gl` | 选择本地版本 (OURS) |
| `<leader>gR` | 选择远程版本 (THEIRS) |
| `<leader>gB` | 选择共同祖先 (BASE) |
| `<leader>gA` | 保留全部三方 |
| `<leader>gX` | 删除整个冲突块 |
| `<leader>gb` | 放弃修改重载文件（应急） |
| `]x` / `[x` | 跳到下/上一个冲突块 |
| `<Tab>` / `<S-Tab>` | Diffview 内置：跳到下/上一个修改文件 |
| `]c` / `[c` | 同一文件内 diff 块跳转 |

合并视图布局改为 `diff3_mixed`（更直观的 3-way merge），开启字符级 diff（`diffopt: algorithm:histogram, linematch:60`）。

文件：`lua/keymaps.lua`、`lua/plugins/editor.lua`

### 🔍 Telescope 搜索覆盖全部文件
`<leader>ff`（find_files）、`<leader>fg`（live_grep）、`<leader>fs`（grep_string）统一行为：
- 包含 `.gitignore` 忽略的文件（加 `--no-ignore`）
- 包含隐藏文件（加 `--hidden`）
- 强制排除 `.git` / `.idea` / `.vscode` / `node_modules` / `.cache` / `dist` / `build` / `.DS_Store`

文件：`lua/plugins/telescope.lua`

### 🔄 外部修改文件自动重载
Claude/git/其他编辑器改了文件，nvim 自动同步：
- `autoread = true`
- `FocusGained` / `BufEnter` / `CursorHold` / `TermLeave` 事件触发 `checktime`
- 文件被外部修改时给通知提示

手动重载：
| 按键 | 作用 |
|------|------|
| `<leader>e` | 检查并重载所有外部修改 |
| `<leader>E` | 强制重载当前文件（丢弃本地改动） |

文件：`lua/options.lua`、`lua/keymaps.lua`

### 📄 Markdown 浏览器预览
- 插件：`iamcco/markdown-preview.nvim`
- 首次安装需在 `~/.local/share/nvim/lazy/markdown-preview.nvim/app/` 下执行 `npm install`（跳过 `install.sh` 以绕开 GitHub API 限流）
- macOS 下通过 `mkdp_browserfunc` 自定义 `open` 命令唤起浏览器

| 按键 | 作用 |
|------|------|
| `<leader>mp` | 切换 Markdown 浏览器预览 |
| `:MarkdownPreview` | 打开预览 |
| `:MarkdownPreviewStop` | 关闭预览 |

文件：`lua/plugins/editor.lua`

### 🎨 代码格式化（conform.nvim，手动触发）
**不再保存时自动格式化**，改为手动按 `<leader>lf` 触发。

已安装的格式化器：

| 文件类型 | 格式化器 |
|---------|---------|
| `.go` | goimports → gofumpt |
| `.lua` | stylua |
| `.json` / `.jsonc` | prettier |
| `.yaml` / `.yml` | prettier |
| `.md` | prettier |
| `.js` / `.ts` / `.jsx` / `.tsx` | prettier |
| `.html` / `.css` / `.scss` | prettier |

prettier 行宽 100，项目里有 `.prettierrc` 会自动读取覆盖。

相关命令：
- `<leader>lf` — 格式化当前文件
- `:ConformInfo` — 查看当前 buffer 会用哪些格式化器

新电脑首次使用时需安装：
```bash
npm install -g prettier
# gofumpt 和 goimports 由 go install 获得
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
# stylua 由 homebrew 安装
brew install stylua
```

文件：`lua/plugins/lsp.lua`

### 🔔 Claude Code 系统通知（macOS）
通过 `~/.claude-internal/settings.json` 的 hooks 配置 osascript 弹 macOS 通知：
- `Stop` → Glass 音效 + "会话已完成"
- `Notification` → Hero 音效 + "需要输入 / 权限确认"
- `SubagentStop` → Pop 音效 + "子 agent 已完成"

### 🔑 which-key 分组
已注册的 leader 分组：`f=查找`、`h=Git`、`x=诊断`、`y=Yank 历史`、`g=Git 工具`、`m=Markdown`。

---

## 📦 关键外部依赖（新机器安装核对）

| 工具 | 用途 | 安装方式 |
|------|------|---------|
| `rg` (ripgrep) | Telescope live_grep | `brew install ripgrep` |
| `fd` | Telescope find_files | `brew install fd` |
| `node` / `npm` | markdown-preview + prettier | `brew install node` |
| `prettier` | JSON/MD/YAML/前端格式化 | `npm install -g prettier` |
| `stylua` | Lua 格式化 | `brew install stylua` |
| `gopls` | Go LSP | `go install golang.org/x/tools/gopls@latest` |
| `gofumpt` | Go 格式化 | `go install mvdan.cc/gofumpt@latest` |
| `goimports` | Go import 整理 | `go install golang.org/x/tools/cmd/goimports@latest` |
| `lua-language-server` | Lua LSP（可选） | `brew install lua-language-server` |

