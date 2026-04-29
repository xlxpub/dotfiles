这是macos上neovim的配置文件，存放目录：~/.config/nvim

在一台新电脑上安装时，直接告诉claude: `该目录是neovim的配置目录，请你帮我完成一些配置、安装，方便我在这台电脑上使用nvim`

---

## 📝 最近配置变更（2026-04）

### 🔍 搜索 Go 结构体的所有方法（跨文件）
**文件**：`lua/keymaps.lua`

光标放在结构体名称上按 `<leader>fm`，自动用正则 `func \(.*\*?StructName\)` 搜索当前项目中该结构体的所有方法（包括指针 receiver 和值 receiver），Telescope 列出结果。

| 快捷键 | 功能 |
|---|---|
| `<leader>fm` | 搜索光标下结构体的所有方法（Go receiver） |

### 🔀 Git 暂存/撤销/提交全流程快捷键
**文件**：`lua/plugins/editor.lua`、`lua/keymaps.lua`

补全了 gitsigns 的暂存/撤销映射，新增终端内 git commit，不用切出 nvim 即可完成完整 git 工作流。

| 快捷键 | 功能 |
|---|---|
| `<leader>hs` | 暂存当前变更块 |
| `<leader>hS` | 暂存整个文件 |
| `<leader>hr` | 重置当前变更块（撤销修改） |
| `<leader>hR` | 重置整个文件（撤销所有修改） |
| `<leader>hu` | 撤销上次暂存（unstage） |
| `<leader>hp` | 预览当前变更块 |
| `<leader>hb` | 查看行 blame |
| `<leader>hd` | Diff 当前文件 |
| `<leader>gg` | 打开 lazygit（浮窗，复杂操作用） |
| `<leader>gc` | Git commit（终端内编辑 message） |
| `<leader>ga` | Git add all + commit |

### 🤖 claudecode.nvim 集成 Claude Code
**文件**：`lua/plugins/claudecode.lua`

将 Claude Code CLI 无缝嵌入 nvim，支持实时上下文同步、diff 审查等。

依赖：`folke/snacks.nvim`（同文件中配置，仅启用 terminal 模块）

| 快捷键 | 功能 |
|---|---|
| `<leader>cc` | 开关 Claude Code 面板 |
| `<leader>cf` | 聚焦 Claude Code 面板 |
| `<leader>cr` | 恢复上次会话 |
| `<leader>cb` | 添加当前文件到上下文 |
| `<leader>cs` | （可视模式）发送选中内容给 Claude |
| `<leader>cy` | 接受 Claude 的 diff 修改（yes）|
| `<leader>cn` | 拒绝 Claude 的 diff 修改（no）|

> 注意：`<leader>ca/ci/co` 已被 LSP 占用（Code Action / 调用树），Claude 快捷键跳过这三个。



### 🗂 JSON 格式化快捷键（jq）
**文件**：`lua/keymaps.lua`

新增三个快捷键，依赖系统 `jq` 命令：

| 快捷键 | 模式 | 功能 |
|---|---|---|
| `<leader>jf` | 普通 | 整个文件格式化（美化多行） |
| `<leader>jf` | 可视 | 只格式化选中区域 |
| `<leader>jm` | 普通 | 压缩为单行（minify） |



### 🔍 Telescope 改为遵守 .gitignore（修复 `.venv` 无法忽略）
**问题**：`<leader>ff` 查找文件时把 `.venv/` 下的 Python 虚拟环境文件全列出来了，即使 `.venv` 已加入 `.gitignore` 也没生效。

**根因**：`lua/plugins/telescope.lua` 里 `find_files` / `live_grep` / `grep_string` 都显式加了 `--no-ignore`，强制让 fd / rg 无视 `.gitignore`。

**修复**：
- 移除所有 `--no-ignore` 参数，让 fd / rg 默认遵守 `.gitignore`（项目级）和 `~/.config/fd/ignore`（全局级）。
- 保留 `--hidden`（仍搜索隐藏文件）。
- 在 `--exclude` / `--glob=!...` 兜底列表里追加 `.venv` / `venv` / `__pycache__`，即使项目未配置 gitignore 也会强制排除。

行为变化：
- 以后把任何目录加到 `.gitignore` 就会被 Telescope 自动忽略，**不用再改 nvim 配置**。
- 要临时搜索被忽略的文件，可以在 Telescope 浮窗里用 `:Telescope find_files no_ignore=true` 覆盖。

文件：`lua/plugins/telescope.lua`

### 🏷 iTerm2 窗口标题显示当前文件/目录
**问题**：nvim 启动后劫持终端标题控制权，zsh 原本的 `precmd` 标题更新失效，iTerm2 回退显示 Profile 名（"Default"）。

**修复**（`lua/options.lua`）：
```lua
opt.title = true
opt.titlestring = [[%{expand("%:t") != "" ? expand("%:t") : fnamemodify(getcwd(), ":t")}]]
opt.titleold = ""
```

效果：
- 打开文件时 → 标题显示文件名（如 `ui.lua`）
- 没打开文件时 → 显示 CWD 最后一级（如 `nvim`）
- 切文件时实时更新
- 退出 nvim 后 zsh 接管，显示目录名

**另需 iTerm2 端配合**：Preferences → Profiles → General → 勾上 `Allow custom window title to be set by applications`（或清空 Custom Window Title 里的 `Default`）。

文件：`lua/options.lua`

### 🔧 修复 gopls 报 "identify GOROOT dir cmd failed"
打开 Go 文件时 gopls 报 `identify GOROOT dir cmd failed with code 1: { "go", "env", "GOROOT" }`。

**根因**：nvim 启动时 `vim.env.GOROOT` 为空（shell 未 export），gopls spawn 子进程跑 `go env GOROOT` 继承的环境里 `GOROOT` 仍为 nil，偶发失败。

**修复**（`lua/options.lua` 末尾）：启动时自动执行 `go env GOROOT` / `GOPATH` 并注入到 `vim.env`，同时确保 `$GOROOT/bin` 和 `$GOPATH/bin` 在 PATH 中。只在检测到 `go` 可执行时触发，对没装 Go 的机器无影响。

文件：`lua/options.lua`

### 🔍 nvim-cmp 启用子串/模糊匹配
补全菜单默认要求前缀匹配，导致输入 `/tmp/2026` 无法匹配 `vim-2026-04-22` 这类候选项。在 `cmp.setup()` 中添加 `matching` 配置，关闭所有匹配限制，允许子串和模糊匹配。

文件：`lua/plugins/lsp.lua`

### 🔧 修复 treesitter-textobjects 键位不生效（2026-04-29）
**问题**：`daf`/`vaf`/`]f` 等 treesitter 文本对象键位完全无效。

**根因**（两层）：
1. **nvim-treesitter v1.0+ 重写了 API**：`setup()` 只接受 `install_dir`，原来的 `ensure_installed`、`highlight`、`indent` 等参数全部被静默忽略，导致 treesitter parser 从未安装，高亮/缩进也未启用
2. **nvim-treesitter-textobjects v1.0+**：`setup()` 不再读取 `keymaps`/`goto_next_start` 等字段自动注册键位

**修复**：
- 用新 API 重写 `treesitter.lua`：
  - `require("nvim-treesitter").install(to_install)` 手动安装 parser
  - `vim.treesitter.start()` 通过 `FileType` autocmd 启用高亮
  - `vim.keymap.set` 手动绑定 textobjects 选择/跳转键位
- 安装系统依赖 `tree-sitter` CLI（编译 parser 必需）：`npm install -g tree-sitter-cli`

**影响的键位**：
- 文本对象选择：`af/if`（函数）、`ac/ic`（类）、`aa/ia`（参数）
- 跳转：`]f/[f`（函数间跳转）、`]c/[c`（类间跳转）

文件：`lua/plugins/treesitter.lua`

### 🔍 JSON 内嵌字段提取预览（je = Json Extract）
JSON 文件中某个字段的值是转义后的 JSON 或 Markdown 字符串，光标放在该值上按快捷键即可提取、反转义并预览。

| 按键 | 作用 |
|------|------|
| `<leader>jej` | 提取 JSON 中的 JSON 字符串（格式化预览） |
| `<leader>jem` | 提取 JSON 中的 Markdown（buffer 预览） |
| `<leader>jeM` | 提取 JSON 中的 Markdown（浏览器预览） |

实现要点：
- 复用已有的 `get_json_string_at_cursor()`（treesitter 优先 + 正则回退）提取字符串
- `vim.json.decode` 解析为 Lua 表，自定义 `json_pretty()` 递归格式化（2 空格缩进、key 排序）
- 在独立 scratch buffer 中显示，`filetype=json`（有语法高亮），`q` 关闭
- `open_in_scratch()` 新增可选 `filetype` / `buf_name` 参数，JSON 预览和 Markdown 预览各用独立 buffer 互不干扰

文件：`lua/tools/json_md_preview.lua`、`lua/keymaps.lua`

### 📄 JSON 中的 Markdown 字段预览
JSON 文件里经常嵌 markdown 字符串（Claude prompts / LLM 配置 / i18n），值含 `\n`、`\t`、`\"` 转义，肉眼看不了。

新增工具：**把光标放到 JSON 字符串字面量上，按快捷键自动反转义并渲染**。

| 按键 | 作用 |
|---|---|
| `<leader>jem` | 提取字段 → 新 buffer 渲染为 markdown（`q` 关闭） |
| `<leader>jeM` | 提取字段 → 新 buffer + 调 `MarkdownPreview` 浏览器预览 |

实现要点（`lua/tools/json_md_preview.lua`）：
- 优先用 **treesitter** 定位光标所在的 `string` 节点（精准，支持跨行字符串）
- 取节点 raw 文本后用 `vim.json.decode` 反转义（`\n` → 真实换行、`\"` → `"`）
- treesitter parser 未就绪时回退到 lua 正则按行匹配 `"key": "value"`
- 渲染目标 buffer：`buftype=nofile` + `filetype=markdown` + `q` 关闭
- 预览窗口自动软换行：`wrap` + `linebreak`（英文单词不切断）+ `breakindent`（续行缩进对齐）+ `showbreak = ↪`（续行提示符），关闭 `number/signcolumn` 腾出宽度
- **复用预览 buffer**：多次调用 `<leader>jem` 不会堆叠窗口，也不会因重名触发 `E95`；`q` 只关窗、不销毁，下次直接重用；每次渲染后光标回顶部

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

### 🔍 Telescope 搜索覆盖全部文件（已于 2026-04 调整）
~~`<leader>ff`（find_files）、`<leader>fg`（live_grep）、`<leader>fs`（grep_string）统一行为：包含 `.gitignore` 忽略的文件（加 `--no-ignore`）、包含隐藏文件（加 `--hidden`）、强制排除常见产物目录。~~

**已更新**：已移除 `--no-ignore`，现在**默认遵守 `.gitignore`**。详见上方"Telescope 改为遵守 .gitignore"一节。

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
已注册的 leader 分组：`f=查找`、`h=Git`、`x=诊断`、`y=Yank 历史`、`g=Git 工具`、`m=Markdown`、`j=JSON`、`je=Json Extract`。

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
| `tree-sitter-cli` | treesitter parser 编译 | `npm install -g tree-sitter-cli` |
| `lua-language-server` | Lua LSP（可选） | `brew install lua-language-server` |

