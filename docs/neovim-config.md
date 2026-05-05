# Neovim 核心配置

> 完成本文后你将拥有：lazy.nvim 插件管理器、主题、文件树、模糊搜索、状态栏、语法高亮、代码补全框架。

---

## 1. 入口文件 `init.lua`

```bash
cat > ~/.config/nvim/init.lua << 'EOF'
-- 加载顺序：选项 → 键位 → 插件管理器 → 插件
require("options")
require("keymaps")
require("lazy-bootstrap")
EOF
```

---

## 2. 基础选项 `lua/options.lua`

```bash
cat > ~/.config/nvim/lua/options.lua << 'EOF'
local opt = vim.opt

-- 行号
opt.number = true           -- 显示行号
opt.relativenumber = true   -- 相对行号（方便用 5j 跳转）

-- 缩进
opt.tabstop = 2             -- Tab 宽度
opt.shiftwidth = 2          -- 缩进宽度
opt.expandtab = true        -- Tab 转空格
opt.autoindent = true
opt.smartindent = true

-- 搜索
opt.hlsearch = false        -- 搜索后不持续高亮
opt.incsearch = true        -- 输入时实时高亮
opt.ignorecase = true       -- 搜索忽略大小写
opt.smartcase = true        -- 含大写时区分大小写

-- 外观
opt.termguicolors = true    -- 24位色彩
opt.signcolumn = "yes"      -- 始终显示 sign 列（避免跳动）
opt.cursorline = true       -- 高亮当前行
opt.scrolloff = 8           -- 光标距屏幕边缘保留 8 行
opt.sidescrolloff = 8
opt.wrap = false            -- 不自动换行

-- 系统剪贴板（macOS）
opt.clipboard = "unnamedplus"

-- 分割窗口方向
opt.splitbelow = true
opt.splitright = true

-- 文件
opt.swapfile = false
opt.backup = false
opt.undofile = true         -- 持久化撤销历史

-- 补全菜单
opt.completeopt = "menu,menuone,noselect"

-- 更新时间（影响 CursorHold 等事件）
opt.updatetime = 250
opt.timeoutlen = 300        -- 键位超时时间（ms）

-- 鼠标
opt.mouse = "a"
EOF
```

---

## 3. 键位映射 `lua/keymaps.lua`

```bash
cat > ~/.config/nvim/lua/keymaps.lua << 'EOF'
local map = vim.keymap.set

-- Leader 键设为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ══════════════════════════════
--  普通模式
-- ══════════════════════════════

-- 保存 / 退出
map("n", "<leader>w", "<cmd>w<cr>",  { desc = "保存文件" })
map("n", "<leader>q", "<cmd>q<cr>",  { desc = "退出" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "强制退出全部" })

-- 清除搜索高亮
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "清除高亮" })

-- 上下移动时居中
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- 窗口切换（不需要 Ctrl-w 前缀）
map("n", "<C-h>", "<C-w>h", { desc = "切换到左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切换到下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切换到上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切换到右窗口" })

-- 窗口大小调整
map("n", "<C-Up>",    "<cmd>resize +2<cr>")
map("n", "<C-Down>",  "<cmd>resize -2<cr>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>")

-- Buffer 切换
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个 buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "下一个 buffer" })

-- 行移动（可视模式下移动选中行）
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "下移选中行" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "上移选中行" })

-- 粘贴时不覆盖寄存器
map("v", "p", '"_dP', { desc = "粘贴不污染寄存器" })

-- ══════════════════════════════
--  文件树（NvimTree）
-- ══════════════════════════════
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "文件树开关" })

-- ══════════════════════════════
--  Telescope 模糊搜索
-- ══════════════════════════════
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",  { desc = "查找文件" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   { desc = "全文搜索" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",     { desc = "搜索 buffer" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",   { desc = "搜索帮助" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",    { desc = "最近文件" })

-- ══════════════════════════════
--  LSP 键位（在 lsp.lua 中定义，此处仅备注）
-- ══════════════════════════════
-- gd  → 跳转到定义
-- gr  → 查看引用
-- K   → 悬浮文档
-- <leader>rn → 重命名
-- <leader>ca → Code Action
-- <leader>d  → 诊断列表
EOF
```

---

## 4. 插件管理器 `lua/lazy-bootstrap.lua`

[lazy.nvim](https://github.com/folke/lazy.nvim) 是目前最主流的 Neovim 插件管理器，首次运行时自动安装。

```bash
cat > ~/.config/nvim/lua/lazy-bootstrap.lua << 'EOF'
-- 自动安装 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 加载所有插件配置
require("lazy").setup("plugins", {
  change_detection = { notify = false },  -- 配置变更时不弹通知
})
EOF
```

---

## 5. UI 插件 `lua/plugins/ui.lua`

```bash
cat > ~/.config/nvim/lua/plugins/ui.lua << 'EOF'
return {
  -- ── 主题：tokyonight ──────────────────────────
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,    -- 最先加载
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- ── 状态栏：lualine ───────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = "|",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },   -- 显示相对路径
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── 文件树：nvim-tree ─────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- 禁用 netrw（nvim-tree 替代它）
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          group_empty = true,   -- 空目录合并显示
          icons = { show = { git = true } },
        },
        filters = { dotfiles = false },  -- 显示隐藏文件
      })
    end,
  },

  -- ── 标签页：bufferline ────────────────────────
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",        -- 标签页上显示 LSP 诊断
          offsets = {{
            filetype = "NvimTree",
            text = "文件树",
            highlight = "Directory",
            separator = true,
          }},
        },
      })
    end,
  },

  -- ── 开始界面：alpha-nvim ──────────────────────
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.buttons.val = {
        dashboard.button("f", "  查找文件",   "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "  最近文件",   "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "  全文搜索",   "<cmd>Telescope live_grep<cr>"),
        dashboard.button("e", "  文件树",     "<cmd>NvimTreeToggle<cr>"),
        dashboard.button("q", "  退出",       "<cmd>qa<cr>"),
      }
      require("alpha").setup(dashboard.config)
    end,
  },

  -- ── 缩进线 ────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({ indent = { char = "▏" } })
    end,
  },

  -- ── 颜色代码预览 ──────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
EOF
```

---

## 6. 编辑器增强 `lua/plugins/editor.lua`

```bash
cat > ~/.config/nvim/lua/plugins/editor.lua << 'EOF'
return {
  -- ── 自动括号配对 ──────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
    end,
  },

  -- ── 注释：gcc 注释行，gbc 注释块 ─────────────
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    config = true,
  },

  -- ── Git 集成（行变更标记）─────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    config = function()
      require("gitsigns").setup({
        signs = {
          add    = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]h", gs.next_hunk,         "下一个 Git 变更")
          map("n", "[h", gs.prev_hunk,         "上一个 Git 变更")
          map("n", "<leader>hs", gs.stage_hunk,  "暂存当前变更块")
          map("n", "<leader>hr", gs.reset_hunk,  "重置当前变更块")
          map("n", "<leader>hp", gs.preview_hunk, "预览当前变更块")
          map("n", "<leader>hb", gs.blame_line,  "查看行 blame")
        end,
      })
    end,
  },

  -- ── 包围符操作（ysw" 给单词加引号等）─────────
  {
    "kylechui/nvim-surround",
    event = "BufReadPost",
    config = true,
  },

  -- ── 快速跳转 ──────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,   desc = "Flash 跳转" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- ── 多光标标记（<leader>m 标记单词）──────────
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({ delay = 200 })
    end,
  },

  -- ── 问题面板 ──────────────────────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>",                 desc = "Trouble 开关" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "工作区诊断" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "文件诊断" },
    },
    config = true,
  },

  -- ── which-key：按键提示 ───────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
      -- 注册 leader 分组标签
      require("which-key").register({
        ["<leader>f"] = { name = "查找" },
        ["<leader>h"] = { name = "Git" },
        ["<leader>x"] = { name = "诊断" },
      })
    end,
  },
}
EOF
```

---

## 7. 模糊搜索 `lua/plugins/telescope.lua`

```bash
cat > ~/.config/nvim/lua/plugins/telescope.lua << 'EOF'
return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- C 扩展加速排序
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,          -- 包含隐藏文件
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
          },
        },
      })

      telescope.load_extension("fzf")
    end,
  },
}
EOF
```

---

## 8. 语法高亮 `lua/plugins/treesitter.lua`

```bash
cat > ~/.config/nvim/lua/plugins/treesitter.lua << 'EOF'
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 自动安装下列语言的语法解析器
        ensure_installed = {
          "go", "gomod", "gosum",
          "python",
          "javascript", "typescript", "tsx",
          "json", "yaml", "toml",
          "lua", "bash",
          "markdown", "markdown_inline",
          "html", "css",
          "dockerfile",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        -- 增强文本对象（需要 nvim-treesitter-textobjects）
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",  -- 选中整个函数
              ["if"] = "@function.inner",  -- 选中函数体
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer", -- 选中参数
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",  -- 跳到下一个函数
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
}
EOF
```

---

## 9. 首次启动

配置文件全部创建完成后，启动 Neovim：

```bash
nvim
```

**首次启动会自动：**
1. 下载 lazy.nvim 插件管理器
2. 安装所有配置的插件（约需 1～3 分钟，取决于网速）
3. Treesitter 会在后台编译语法解析器

**查看安装进度：**

```
:Lazy          # 打开插件管理界面
:TSInstallInfo # 查看 Treesitter 解析器状态
```

---

## 10. 常用操作验证

```
<leader>e       → 打开文件树
<leader>ff      → 模糊搜索文件
<leader>fg      → 全文搜索
<Space>         → 等待后弹出 which-key 提示
gcc             → 注释/取消注释当前行
s{字母}         → Flash 快速跳转
ys iw "         → 给单词加双引号（nvim-surround）
```

---

> ✅ 核心配置完成，下一步：[neovim-lsp.md](./neovim-lsp.md) — 配置 LSP、代码补全、格式化
