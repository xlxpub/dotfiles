所有配置文件已读完，以下是完整梳理：

---

## 一、UI 类插件（`ui.lua`）

### 1. github-nvim-theme — 主题
GitHub Dark Dimmed 配色，无快捷键。

### 2. lualine.nvim — 底部状态栏
显示模式/分支/诊断/文件名/编码/位置，无快捷键。

### 3. nvim-tree.lua — 文件树
| 快捷键      | 作用         |
| ----------- | ------------ |
| `<leader>e` | 文件树开关   |
| `<leader>E` | 定位当前文件 |

### 4. bufferline.nvim — 顶部标签页
| 快捷键    | 作用          |
| --------- | ------------- |
| `Shift+h` | 上一个 buffer |
| `Shift+l` | 下一个 buffer |

### 5. alpha-nvim — 启动页面
启动时显示仪表盘，按 `f/r/g/e/q` 快速操作。

### 6. indent-blankline.nvim — 缩进参考线
自动显示，无快捷键。

### 7. nvim-colorizer.lua — 颜色代码预览
`#ff0000` 这类颜色代码自动显示对应颜色，无快捷键。

### 8. aerial.nvim — 符号大纲 / 面包屑
| 快捷键       | 作用               |
| ------------ | ------------------ |
| `<leader>a`  | 大纲面板开关       |
| `[a` / `]a`  | 上/下一个符号      |
| `<leader>fa` | Telescope 符号搜索 |

---

## 二、搜索类（`telescope.lua`）

### 9. telescope.nvim — 模糊搜索
| 快捷键       | 作用                  |
| ------------ | --------------------- |
| `<leader>ff` | 查找文件              |
| `<leader>fg` | 全文搜索（live_grep） |
| `<leader>fb` | 搜索 buffer           |
| `<leader>fh` | 搜索帮助              |
| `<leader>fr` | 最近文件              |

---

## 三、LSP 类（`lsp.lua`）

### 10. mason.nvim + mason-lspconfig.nvim — LSP 安装管理
自动安装 `gopls`、`lua_ls`，命令 `:Mason` 打开面板。

### 11. nvim-lspconfig — LSP 配置
| 快捷键       | 作用                  |
| ------------ | --------------------- |
| `gd`         | 跳转到定义            |
| `gD`         | 跳转到声明            |
| `gi`         | 跳转到实现            |
| `gt`         | 跳转到类型定义        |
| `gr`         | 查看引用（Telescope） |
| `K`          | 悬浮文档              |
| `Ctrl+k`     | 函数签名              |
| `<leader>rn` | 重命名                |
| `<leader>ca` | Code Action           |
| `<leader>ci` | 入调用树              |
| `<leader>co` | 出调用树              |
| `[d` / `]d`  | 上/下一个诊断         |
| `<leader>dl` | 诊断列表              |
| `<leader>df` | 诊断详情浮窗          |
| `<leader>fs` | 当前文件符号          |
| `<leader>fS` | 工作区符号            |

### 12. nvim-cmp — 代码补全
| 快捷键              | 模式   | 作用                    |
| ------------------- | ------ | ----------------------- |
| `Ctrl+n`            | insert | 下一个候选              |
| `Ctrl+p`            | insert | 上一个候选              |
| `Ctrl+d`            | insert | 文档向下滚动            |
| `Ctrl+u`            | insert | 文档向上滚动            |
| `Ctrl+Space`        | insert | 手动触发补全            |
| `Ctrl+e`            | insert | 取消补全                |
| `Enter`             | insert | 确认选择                |
| `Tab` / `Shift+Tab` | insert | 切换候选 / snippet 跳转 |

补全源：LSP → LuaSnip → buffer → path

### 13. conform.nvim — 代码格式化
| 快捷键       | 作用            |
| ------------ | --------------- |
| `<leader>lf` | 格式化文件/选区 |

支持 Go（goimports+gofumpt）、Lua（stylua）、JSON/YAML/MD/前端（prettier）。

---

## 四、Treesitter 类（`treesitter.lua`）

### 14. nvim-treesitter — 语法高亮/缩进
自动启用，无快捷键。

### 15. nvim-treesitter-textobjects — 文本对象
| 快捷键      | 模式            | 作用                |
| ----------- | --------------- | ------------------- |
| `af` / `if` | visual/operator | 选中整个函数/函数体 |
| `ac` / `ic` | visual/operator | 选中整个类/类体     |
| `aa` / `ia` | visual/operator | 选中整个参数/参数值 |
| `]f` / `[f` | normal          | 跳到下/上一个函数   |
| `]c` / `[c` | normal          | 跳到下/上一个 class |

---

## 五、编辑增强类（`editor.lua`）

### 16. markdown-preview.nvim — Markdown 浏览器预览
| 快捷键       | 作用                     |
| ------------ | ------------------------ |
| `<leader>mp` | 切换 Markdown 浏览器预览 |

### 17. nvim-autopairs — 自动括号配对
输入 `(` 自动补全 `)`，无快捷键。

### 18. Comment.nvim — 注释
| 快捷键        | 模式   | 作用                |
| ------------- | ------ | ------------------- |
| `gcc`         | normal | 注释/取消注释当前行 |
| `gbc`         | normal | 块注释当前行        |
| `gc`          | visual | 注释选中行          |
| `gb`          | visual | 块注释选中行        |
| `gcO` / `gco` | normal | 上方/下方插入注释行 |
| `gcA`         | normal | 行尾追加注释        |

### 19. gitsigns.nvim — Git 行变更标记
| 快捷键       | 作用                 |
| ------------ | -------------------- |
| `]h` / `[h`  | 下/上一个 Git 变更块 |
| `<leader>hs` | 暂存当前变更块       |
| `<leader>hr` | 重置当前变更块       |
| `<leader>hp` | 预览当前变更块       |
| `<leader>hb` | 查看行 blame         |

### 20. nvim-surround — 包围符操作
| 快捷键  | 作用                 | 示例            |
| ------- | -------------------- | --------------- |
| `ysiw"` | 给单词加 `""`        | hello → "hello" |
| `yss"`  | 给整行加 `""`        |                 |
| `S"`    | visual 选中后加 `""` |                 |
| `cs'"`  | `'` 换成 `"`         | 'hi' → "hi"     |
| `ds"`   | 删除 `""`            | "hi" → hi       |

### 21. flash.nvim — 快速跳转
| 快捷键 | 作用                               |
| ------ | ---------------------------------- |
| `s`    | Flash 跳转（输入字符后标记跳转）   |
| `S`    | Flash Treesitter（按语法结构跳转） |

### 22. vim-illuminate — 当前单词高亮
光标停留 200ms 自动高亮同名符号，无快捷键。

### 23. trouble.nvim — 诊断问题面板
| 快捷键       | 作用         |
| ------------ | ------------ |
| `<leader>xx` | Trouble 开关 |
| `<leader>xw` | 工作区诊断   |
| `<leader>xd` | 文件诊断     |

### 24. yanky.nvim — Yank 历史
| 快捷键              | 作用                   |
| ------------------- | ---------------------- |
| `p` / `P`           | 粘贴（自动记录历史）   |
| `Ctrl+p` / `Ctrl+n` | 粘贴后循环切换历史条目 |

### 25. which-key.nvim — 按键提示
按 `<leader>` 后等待，自动弹出所有可用键位提示。

### 26. diffview.nvim — Git 冲突解决
| 快捷键       | 作用                  |
| ------------ | --------------------- |
| `<leader>gd` | 打开 Diffview         |
| `<leader>gD` | 关闭 Diffview    [118;1:3u     |
| `<leader>gl` | 选择本地版本 (OURS)   |
| `<leader>gR` | 选择远程版本 (THEIRS) |
| `<leader>gB` | 选择共同祖先 (BASE)   |
| `<leader>gA` | 保留全部三方          |
| `<leader>gX` | 删除整个冲突块        |
| `<leader>gb` | 放弃修改重载文件      |
| `]x` / `[x`  | 跳到下/上一个冲突块   |

---

## 六、自定义工具（`keymaps.lua` + `tools/`）

### JSON 内嵌字段提取预览
| 快捷键        | 作用                                   |
| ------------- | -------------------------------------- |
| `<leader>jej` | 提取 JSON 中的 JSON 字段（格式化预览） |
| `<leader>jem` | 提取 JSON 中的 Markdown（buffer 预览） |
| `<leader>jeM` | 提取 JSON 中的 Markdown（浏览器预览）  |

### 通用快捷键
| 快捷键              | 作用           |
| ------------------- | -------------- |
| `<leader>w`         | 保存文件       |
| `<leader>q`         | 退出           |
| `<leader>Q`         | 强制退出全部   |
| `Esc`               | 清除搜索高亮   |
| `Ctrl+d/u`          | 半页滚动并居中 |
| `Ctrl+h/j/k/l`      | 窗口切换       |
| `Ctrl+↑↓←→`         | 窗口大小调整   |
| `J` / `K`（visual） | 上下移动选中行 |
