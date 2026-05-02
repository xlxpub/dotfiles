return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- nvim-treesitter v1.0+ 新 API（移除了 nvim-treesitter.configs）
      require("nvim-treesitter").setup({
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
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        fold = { enable = true },  -- 启用折叠
      })

      -- 文本对象（nvim-treesitter-textobjects 独立配置）
      require("nvim-treesitter-textobjects").setup({
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
          set_jumps = true,
        },
      })

      -- move 跳转：新版不支持在 setup() 里配 keymaps，需手动绑定
      -- 跳转前先检查当前 buffer 是否有 treesitter parser，避免在无 parser 的文件类型
      -- （如 .log .txt）上调用时触发 nil score 崩溃（nvim-treesitter-textobjects bug）
      local move = require("nvim-treesitter-textobjects.move")
      local function bind(key, fn, query, desc, fallback_key)
        vim.keymap.set({ "n", "o", "x" }, key, function()
          -- diff 模式下透传给 vim 原生（]c/[c 是 diff 内置跳转）
          if vim.wo.diff and fallback_key then
            vim.cmd("normal! " .. fallback_key)
            return
          end
          local ok = pcall(vim.treesitter.get_parser, 0)
          if not ok then
            vim.notify("当前文件类型无 treesitter parser，跳转不可用", vim.log.levels.WARN)
            return
          end
          fn(query)
        end, { desc = desc })
      end
      bind("]f", move.goto_next_start,     "@function.outer", "下一个函数开头")
      bind("[f", move.goto_previous_start, "@function.outer", "上一个函数开头")
      bind("]F", move.goto_next_end,       "@function.outer", "下一个函数结尾")
      bind("[F", move.goto_previous_end,   "@function.outer", "上一个函数结尾")
      -- ]c/[c：diff 模式下透传给 vim 原生（跳冲突块），否则跳 treesitter class
      bind("]c", move.goto_next_start,     "@class.outer", "下一个 class（diff 模式跳冲突）",    "]c")
      bind("[c", move.goto_previous_start, "@class.outer", "上一个 class（diff 模式跳冲突）", "[c")
    end,
  },
}
