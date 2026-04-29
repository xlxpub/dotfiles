return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- ── nvim-treesitter v1.0+：setup() 只接受 install_dir ──
      -- ensure_installed / highlight / indent 等旧字段已移除，需用新 API

      -- 确保安装指定的 parser（异步，不阻塞启动）
      local ensure = {
        "go", "gomod", "gosum",
        "python",
        "javascript", "typescript", "tsx",
        "json", "yaml", "toml",
        "lua", "bash",
        "markdown", "markdown_inline",
        "html", "css",
        "dockerfile",
      }
      local installed = require("nvim-treesitter").get_installed()
      local to_install = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, ensure)
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- ── 启用 treesitter 高亮 / 缩进（nvim 原生 API）──
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf = args.buf
          local ft = vim.bo[buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          -- 仅对有 parser 的文件类型启用
          local ok = pcall(vim.treesitter.start, buf, lang)
          if ok then
            -- 启用基于 treesitter 的缩进
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- ── 文本对象（nvim-treesitter-textobjects v1.0+）──
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      -- ── 文本对象选择键位 ──────────────────────
      local ts_select = require("nvim-treesitter-textobjects.select")
      local select_maps = {
        ["af"] = "@function.outer",  -- 选中整个函数
        ["if"] = "@function.inner",  -- 选中函数体
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer", -- 选中参数
        ["ia"] = "@parameter.inner",
      }
      for key, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          ts_select.select_textobject(query)
        end, { desc = "TS: " .. query })
      end

      -- ── 文本对象跳转键位 ──────────────────────
      local ts_move = require("nvim-treesitter-textobjects.move")
      local move_maps = {
        ["]f"] = { fn = ts_move.goto_next_start,     query = "@function.outer", desc = "下一个函数" },
        ["]c"] = { fn = ts_move.goto_next_start,     query = "@class.outer",    desc = "下一个 class" },
        ["[f"] = { fn = ts_move.goto_previous_start, query = "@function.outer", desc = "上一个函数" },
        ["[c"] = { fn = ts_move.goto_previous_start, query = "@class.outer",    desc = "上一个 class" },
      }
      for key, m in pairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          m.fn(m.query)
        end, { desc = m.desc })
      end
    end,
  },
}
