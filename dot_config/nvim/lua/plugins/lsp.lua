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

  -- 文档（nvim 原生，0.10+ 自带圆角边框 + markdown 渲染）
  map("n", "K",     vim.lsp.buf.hover,           "悬浮文档")
  map("n", "<C-k>", vim.lsp.buf.signature_help,  "函数签名")

  -- 重构（nvim 原生）
  map("n", "<leader>rn", vim.lsp.buf.rename,      "重命名")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("v", "<leader>ca", vim.lsp.buf.code_action, "Code Action（选区）")

  -- 调用层级（nvim 原生）
  map("n", "<leader>ci", vim.lsp.buf.incoming_calls, "入调用树")
  map("n", "<leader>co", vim.lsp.buf.outgoing_calls, "出调用树")

  -- 诊断
  map("n", "[d",         vim.diagnostic.goto_prev,         "上一个诊断")
  map("n", "]d",         vim.diagnostic.goto_next,         "下一个诊断")
  map("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", "诊断列表")
  map("n", "<leader>df", vim.diagnostic.open_float,        "诊断详情")

  -- 符号搜索
  map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",  "当前文件符号")
  map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "工作区符号")

  -- 格式化键位从 LSP on_attach 移到了 conform.nvim 的 keys（全局生效，无需 LSP）
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  诊断样式
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vim.diagnostic.config({
  virtual_text  = { prefix = "●", source = "if_many" },
  float         = { border = "rounded", source = "always" },
  signs         = true,
  underline     = true,
  update_in_insert = false,
  severity_sort = true,
})

-- hover / signature_help / 所有 LSP 浮窗统一加圆角边框
-- （取代 lspsaga；nvim 0.11+ 已弃用 vim.lsp.with，改用 monkey-patch open_floating_preview）
do
  local orig = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, syntax, opts, ...)
  end
end

local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- ── Mason-LSPconfig：自动安装 LSP ────────
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed      = { "gopls", "lua_ls" },
        automatic_installation = true,
      })
    end,
  },

  -- ── nvim-lspconfig：提供服务器默认配置 ───
  --    （nvim 0.11+ 使用 vim.lsp.config/enable，
  --     nvim-lspconfig 负责注册 cmd/filetypes/root_markers）
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- 添加位置编码到 capabilities
      capabilities.offsetEncoding = { "utf-8" }

      -- ── 全局默认：所有 LSP 共享 ──────────
      vim.lsp.config("*", {
        on_attach    = on_attach,
        capabilities = capabilities,
      })

      -- ── Go：gopls ────────────────────────
      vim.lsp.config("gopls", {
        cmd = { "gopls", "serve" },
        settings = {
          gopls = {
            gofumpt      = true,
            staticcheck  = true,
            analyses     = { unusedparams = true, shadow = true },
            hints        = {
              assignVariableTypes    = true,
              compositeLiteralFields = true,
              functionTypeParameters = true,
              parameterNames         = true,
              rangeVariableTypes     = true,
            },
          },
        },
      })

      -- ── Lua（编辑 Neovim 配置用）────────
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime     = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace   = {
              library        = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- 启用所有已配置的服务器
      vim.lsp.enable({ "gopls", "lua_ls" })
    end,
  },

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --  代码补全：nvim-cmp
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- 允许子串匹配（输入 2026 可匹配 vim-2026-04-22）
        matching = {
          disallow_fuzzy_matching        = false,
          disallow_fullfuzzy_matching    = false,
          disallow_partial_fuzzy_matching = false,
          disallow_partial_matching      = false,
          disallow_prefix_unmatching     = false,
        },
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-d>"]     = cmp.mapping.scroll_docs(4),
          ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
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
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "buffer",   priority = 500  },
          { name = "path",     priority = 250  },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode         = "symbol_text",
            maxwidth     = 50,
            ellipsis_char = "...",
          }),
        },
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
  --  （lspsaga 已移除：改用 nvim 原生 LSP UI + aerial 面包屑/outline）
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --  代码格式化：conform.nvim（仅手动触发）
  --  - <leader>lf  格式化当前文件
  --  - :ConformInfo 查看当前 buffer 的格式化器
  -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd   = "ConformInfo",
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "格式化文件/选区",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go         = { "goimports", "gofumpt" },
          lua        = { "stylua" },
          json       = { "prettier" },
          jsonc      = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          html       = { "prettier" },
          css        = { "prettier" },
          scss       = { "prettier" },
        },
        -- 已关闭保存时自动格式化：通过 <leader>lf 手动触发
        -- format_on_save = { timeout_ms = 3000, lsp_fallback = true },
        formatters = {
          prettier = {
            prepend_args = { "--print-width", "100" },
          },
        },
      })
    end,
  },
}
