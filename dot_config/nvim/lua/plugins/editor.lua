return {
  -- ── Markdown 浏览器预览 ───────────────────────
  --   :MarkdownPreview       启动浏览器预览
  --   :MarkdownPreviewStop   关闭
  --   :MarkdownPreviewToggle 切换
  --
  -- 首次安装后需要在插件目录手动构建一次：
  --   cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm install
  --   （在 GitHub release 被限流时，跳过 install.sh 直接 npm install）
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown 浏览器预览" },
    },
    init = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "light"
      -- macOS：浏览器默认不会被插件唤起，用 g:mkdp_browserfunc 自定义启动逻辑
      vim.g.mkdp_browserfunc = "g:Mkdp_browserfunc_default"
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_page_title = "「${name}」"

      -- 自定义函数：用 macOS 的 `open` 命令打开 URL
      vim.cmd([[
        function! g:Mkdp_browserfunc_default(url)
          call system('open ' . shellescape(a:url))
        endfunction
      ]])
    end,
  },

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
          map("n", "]h", gs.next_hunk,          "下一个 Git 变更")
          map("n", "[h", gs.prev_hunk,          "上一个 Git 变更")
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
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash 跳转" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- ── 当前单词高亮 ──────────────────────────────
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
      { "<leader>xx", "<cmd>TroubleToggle<cr>",                        desc = "Trouble 开关" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",  desc = "工作区诊断" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",   desc = "文件诊断" },
    },
    config = true,
  },

  -- ── Yank 历史 ─────────────────────────────────
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    config = function()
      require("yanky").setup()
      -- 替换默认 p/P，自动记录 yank 历史
      vim.keymap.set({ "n", "x" }, "p",    "<Plug>(YankyPutAfter)")
      vim.keymap.set({ "n", "x" }, "P",    "<Plug>(YankyPutBefore)")
      -- 粘贴后按 <C-p>/<C-n> 循环切换历史条目
      vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)")
      vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)")
    end,
  },

  -- ── which-key：按键提示 ───────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
      -- 注册 leader 分组标签
      require("which-key").add({
        { "<leader>f", group = "查找" },
        { "<leader>h", group = "Git" },
        { "<leader>x", group = "诊断" },
        { "<leader>y", group = "Yank 历史" },
        { "<leader>g", group = "Git 工具" },
        { "<leader>m", group = "Markdown" },
        -- 下面几条是 Vim 内置命令（非 keymap），在 which-key 里补充说明
        { "]c", desc = "下一个 diff 改动点（diff 模式）/ 下一个 class（普通模式）" },
        { "[c", desc = "上一个 diff 改动点（diff 模式）/ 上一个 class（普通模式）" },
      })
    end,
  },

  -- ── Git 冲突解决：diffview ─────────────────────
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "打开冲突查看器" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "关闭冲突查看器" },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,  -- 增强差异高亮（依赖主题的 DiffAdd/DiffChange 等）
        use_icons = true,         -- 使用图标
        -- 字符级 diff：不光整行变色，修改的具体字符也高亮
        diff_binaries = false,
        view = {
          default = { winbar_info = true },
          merge_tool = {
            layout = "diff3_mixed",  -- 3-way 合并：OURS | 结果 | THEIRS（更直观）
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
      })
      -- 打开字符级 diff 算法
      vim.opt.diffopt:append("algorithm:histogram")
      vim.opt.diffopt:append("indent-heuristic")
      vim.opt.diffopt:append("linematch:60")  -- 行内字符级匹配
    end,
  },
}
