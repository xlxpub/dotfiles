# Neovim LSP 配置：代码智能、补全与格式化

> 覆盖语言：Go、Python、JavaScript/TypeScript、通用配置文件（JSON/YAML/TOML）

---

## 概念速览

| 组件 | 作用 |
|------|------|
| **mason.nvim** | LSP/DAP/Formatter 安装管理器（相当于 npm 的作用） |
| **nvim-lspconfig** | 连接 Neovim 与各语言服务器的配置框架 |
| **mason-lspconfig** | mason 与 lspconfig 的桥梁，自动安装并启动 |
| **nvim-cmp** | 代码补全引擎（聚合来自 LSP、代码片段等的补全源） |
| **conform.nvim** | 代码格式化（比 null-ls 更轻量） |
| **nvim-lint** | 代码 Lint（eslint、ruff 等） |

---

## 1. 安装语言服务器依赖

在安装 LSP 服务器之前，需在系统中安装对应的运行时：

```bash
# Go LSP（gopls）
go install golang.org/x/tools/gopls@latest

# Python LSP（pyright）
npm install -g pyright

# 或使用 pipx（推荐）
# pipx install pyright

# TypeScript / JavaScript LSP
npm install -g typescript typescript-language-server

# JSON / YAML / HTML / CSS LSP
npm install -g vscode-langservers-extracted

# TOML LSP（可选）
# mason 会自动安装，无需手动
```

---

## 2. LSP 完整配置 `lua/plugins/lsp.lua`

```bash
cat > ~/.config/nvim/lua/plugins/lsp.lua << 'EOF'
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  辅助函数：LSP 附加时绑定键位
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- 跳转
  map("n", "gd",  vim.lsp.buf.definition,      "跳转到定义")
  map("n", "gD",  vim.lsp.buf.declaration,     "跳转到声明")
  map("n", "gi",  vim.lsp.buf.implementation,  "跳转到实现")
  map("n", "gt",  vim.lsp.buf.type_definition, "跳转到类型定义")
  map("n", "gr",  "<cmd>Telescope lsp_references<cr>", "查看引用")

  -- 文档
  map("n", "K",   vim.lsp.buf.hover,           "悬浮文档")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "函数签名")

  -- 重构
  map("n", "<leader>rn", vim.lsp.buf.rename,        "重命名")
  map("n", "<leader>ca", vim.lsp.buf.code_action,   "Code Action")
  map("v", "<leader>ca", vim.lsp.buf.code_action,   "Code Action（选区）")

  -- 诊断
  map("n", "[d", vim.diagnostic.goto_prev,    "上一个诊断")
  map("n", "]d", vim.diagnostic.goto_next,    "下一个诊断")
  map("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", "诊断列表")
  map("n", "<leader>df", vim.diagnostic.open_float, "诊断详情")

  -- 格式化（交给 conform.nvim，此处手动触发）
  map("n", "<leader>lf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, "格式化文件")
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  诊断样式
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",   -- 多个来源时显示来源名
  },
  float = { border = "rounded", source = "always" },
  signs = true,
  underline = true,
  update_in_insert = false,  -- 插入模式不更新诊断（避免干扰）
  severity_sort = true,
})

-- 诊断图标
local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  各语言服务器配置
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local servers = {
  -- ── Go ──────────────────────────────────
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,           -- 使用 gofumpt 格式化
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },

  -- ── Python ──────────────────────────────
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",   -- off / basic / strict
          autoImportCompletions = true,
        },
      },
    },
  },

  -- ── TypeScript / JavaScript ─────────────
  ts_ls = {},

  -- ── JSON ────────────────────────────────
  jsonls = {
    settings = {
      json = {
        -- 开启 JSON Schema 校验（package.json、tsconfig.json 等）
        validate = { enable = true },
      },
    },
  },

  -- ── YAML ────────────────────────────────
  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = true, url = "" },
        keyOrdering = false,
      },
    },
  },

  -- ── HTML / CSS ──────────────────────────
  html   = {},
  cssls  = {},

  -- ── Lua（编辑 Neovim 配置时有智能提示）──
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  插件声明
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
return {
  -- ── Mason：LSP 安装管理器 ────────────────
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
        },
      })
    end,
  },

  -- ── Mason-LSPconfig 桥梁 ─────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- 自动安装 servers 表中列出的 LSP
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })
    end,
  },

  -- ── nvim-lspconfig：核心 LSP 配置 ────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",   -- 告诉 LSP 客户端支持哪些补全能力
    },
    config = function()
      local lspconfig = require("lspconfig")
      -- cmp_nvim_lsp 扩展 LSP 能力（支持代码片段等）
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      for server_name, server_config in pairs(servers) do
        lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
          on_attach    = on_attach,
          capabilities = capabilities,
        }, server_config))
      end
    end,
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --  代码补全：nvim-cmp
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP 补全源
      "hrsh7th/cmp-buffer",       -- 当前 buffer 单词
      "hrsh7th/cmp-path",         -- 文件路径
      "hrsh7th/cmp-cmdline",      -- 命令行补全
      {
        "L3MON4D3/LuaSnip",       -- 代码片段引擎
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },  -- 预置代码片段库
      },
      "saadparwaiz1/cmp_luasnip", -- LuaSnip 补全源
      "onsails/lspkind.nvim",     -- 补全菜单图标
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- 加载预置代码片段
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- 补全菜单样式
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        -- 键位映射
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]   = cmp.mapping.select_next_item(),  -- 下一项
          ["<C-p>"]   = cmp.mapping.select_prev_item(),  -- 上一项
          ["<C-d>"]   = cmp.mapping.scroll_docs(4),      -- 文档向下滚动
          ["<C-u>"]   = cmp.mapping.scroll_docs(-4),     -- 文档向上滚动
          ["<C-Space>"] = cmp.mapping.complete(),        -- 强制触发补全
          ["<C-e>"]   = cmp.mapping.abort(),             -- 关闭补全
          ["<CR>"]    = cmp.mapping.confirm({ select = false }), -- 确认（不自动选第一项）
          -- Tab 键：补全或 snippet 跳转
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- 补全来源（优先级从高到低）
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "buffer",   priority = 500  },
          { name = "path",     priority = 250  },
        }),

        -- 补全菜单图标
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },

        -- 不在注释中触发补全
        enabled = function()
          local context = require("cmp.config.context")
          if vim.api.nvim_get_mode().mode == "c" then return true end
          return not context.in_treesitter_capture("comment")
             and not context.in_syntax_group("Comment")
        end,
      })

      -- 命令行 "/" 搜索补全
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- 命令行 ":" 补全
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --  代码格式化：conform.nvim
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go         = { "goimports", "gofumpt" },  -- Go：先整理 import，再格式化
          python     = { "ruff_format", "black" },  -- Python：ruff 优先，fallback black
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          html       = { "prettier" },
          css        = { "prettier" },
          markdown   = { "prettier" },
          lua        = { "stylua" },
        },
        -- 保存时自动格式化
        format_on_save = {
          timeout_ms = 3000,
          lsp_fallback = true,   -- 无专用格式化工具时使用 LSP
        },
      })
    end,
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --  Lint：nvim-lint
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python     = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        go         = { "golangcilint" },
      }
      -- 保存时触发 lint
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --  格式化工具自动安装（mason-conform 联动）
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {
          "goimports", "gofumpt",    -- Go
          "ruff", "black",           -- Python
          "prettier",                -- JS/TS/JSON/YAML/HTML
          "eslint_d",                -- JS/TS lint
          "stylua",                  -- Lua
        },
        automatic_installation = true,
      })
    end,
  },
}
EOF
```

---

## 3. 重新加载配置

```bash
# 在 Neovim 中执行
:Lazy sync          # 安装/更新所有插件
:Mason              # 打开 Mason 面板，确认 LSP 已安装
:LspInfo            # 查看当前 buffer 关联的 LSP
:ConformInfo        # 查看格式化工具状态
```

---

## 4. Go 专项配置

打开一个 `.go` 文件后：

```
K           → 查看函数文档
gd          → 跳到定义
gr          → 查看所有引用
]d / [d     → 下一个/上一个错误
<leader>ca  → 自动补全 import、提取变量、生成测试等
<leader>lf  → 手动格式化（保存时自动触发）
```

安装 `golangci-lint`（本地 lint 工具）：

```bash
brew install golangci-lint
```

---

## 5. Python 专项配置

推荐搭配虚拟环境使用，pyright 会自动检测 `.venv`：

```bash
python3 -m venv .venv
source .venv/bin/activate

# 安装 ruff（快速 lint + 格式化）
pip install ruff black
```

在 Neovim 中可通过 `:LspInfo` 确认 pyright 使用了正确的 Python 解释器。

若需切换 Python 版本，在项目根目录创建 `pyrightconfig.json`：

```json
{
  "venvPath": ".",
  "venv": ".venv",
  "pythonVersion": "3.11"
}
```

---

## 6. TypeScript/JavaScript 专项配置

项目中通常需要 ESLint 配置文件，lint_d 才会生效：

```bash
# 安装 eslint（项目级别）
npm install -D eslint

# 初始化配置（根据项目类型选择）
npx eslint --init
```

Prettier 会自动读取项目中的 `.prettierrc` 配置文件。

---

## 7. 常用 LSP 键位汇总

| 键位 | 说明 |
|------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gi` | 跳转到实现 |
| `gt` | 跳转到类型定义 |
| `gr` | 查看所有引用（Telescope） |
| `K` | 悬浮显示文档 |
| `<C-k>` | 显示函数签名 |
| `<leader>rn` | 重命名符号 |
| `<leader>ca` | Code Action（自动修复、重构）|
| `<leader>lf` | 手动格式化 |
| `[d` / `]d` | 上/下一个诊断 |
| `<leader>df` | 浮窗显示诊断详情 |
| `<leader>dl` | 诊断列表（Telescope）|
| `<C-n>` / `<C-p>` | 补全菜单上下选择 |
| `<CR>` | 确认补全 |
| `<Tab>` | 补全下一项 / snippet 跳转 |

---

## 8. Mason 常用命令

```
:Mason                  # 打开 Mason 管理界面
:MasonInstall gopls     # 手动安装指定 LSP
:MasonUninstall gopls   # 卸载
:MasonUpdate            # 更新所有已安装工具
```

在 Mason 界面中，按 `i` 安装，`X` 卸载，`U` 更新，`g?` 查看帮助。

---

> ✅ 至此，Neovim IDE 配置全部完成！
>
> **文档目录**：
> - [`vim-cheatsheet.md`](./vim-cheatsheet.md) — Vim 常用操作速查
> - [`neovim-install.md`](./neovim-install.md) — 安装与环境准备
> - [`neovim-config.md`](./neovim-config.md) — 插件管理与 UI 配置
> - [`neovim-lsp.md`](./neovim-lsp.md) — LSP、补全与格式化（本文）
