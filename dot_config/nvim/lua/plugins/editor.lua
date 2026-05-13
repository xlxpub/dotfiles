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
      vim.g.mkdp_browserfunc = "Mkdp_browserfunc_default"
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_page_title = "「${name}」"

      -- 自定义函数：用 macOS 的 `open` 命令打开 URL
      vim.cmd([[
        function! Mkdp_browserfunc_default(url)
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
        -- Git 快捷键说明
        { "<leader>gs", desc = "暂存当前变更块" },
        { "<leader>gr", desc = "重置当前变更块" },
        { "<leader>gp", desc = "预览当前变更块" },
        { "<leader>gb", desc = "查看行 blame" },
        { "<leader>gd", desc = "打开 Diffview" },
        { "<leader>gc", desc = "关闭 Diffview" },
        { "<leader>gf", desc = "当前文件 Git 历史" },
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
        { "]x", desc = "下一个冲突" },
        { "[x", desc = "上一个冲突" },
      })
    end,
  },

  -- ── 输入法自动切换 ────────────────────────────
  --   离开插入模式 → 自动切换到 ABC 英文
  --   进入插入模式 → 恢复离开前的输入法（记住上次状态）
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    config = function()
      require("im_select").setup({
        -- 默认英文输入法标识（ABC）
        default_im_select = "com.apple.keylayout.ABC",
        -- 命令行工具路径（brew 安装）
        default_command = "im-select",
        -- 进入插入模式时恢复离开前的输入法
        set_previous_events = { "InsertEnter" },
        -- 离开插入模式时切换为英文
        set_default_events = { "InsertLeave", "BufEnter", "FocusGained", "CmdlineEnter" },
      })
    end,
  },

}
