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
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("yanky").setup()
      require("telescope").load_extension("yank_history")
      -- 替换默认 p/P，自动记录 yank 历史
      vim.keymap.set({ "n", "x" }, "p",    "<Plug>(YankyPutAfter)")
      vim.keymap.set({ "n", "x" }, "P",    "<Plug>(YankyPutBefore)")
      -- 粘贴后按 <C-p>/<C-n> 循环切换历史条目
      vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)")
      vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)")
      -- Telescope 打开 yank 历史列表
      vim.keymap.set("n", "<leader>ph", "<cmd>Telescope yank_history<cr>", { desc = "Yank 历史列表" })
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
        { "<leader>g", group = "Git" },
        { "<leader>x", group = "诊断" },
        { "<leader>p", group = "复制" },
        { "<leader>m", group = "Markdown" },
        { "<leader>j", group = "JSON" },
        { "<leader>je", group = "Json Extract" },
        -- ] 系列跳转中文描述
        { "]d", desc = "下一个诊断" },
        { "[d", desc = "上一个诊断" },
        { "]h", desc = "下一个 Git 变更" },
        { "[h", desc = "上一个 Git 变更" },
        { "]f", desc = "下一个函数开头" },
        { "[f", desc = "上一个函数开头" },
        { "]F", desc = "下一个函数结尾" },
        { "[F", desc = "上一个函数结尾" },
        { "]c", desc = "下一个 class" },
        { "[c", desc = "上一个 class" },
      })
    end,
  },

}
