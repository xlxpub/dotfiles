-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Git 集成：gitsigns + diffview
--  所有 Git 快捷键统一使用 <leader>g 前缀
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
return {
  -- ── Gitsigns：行变更标记 + hunk 操作 ──────────
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
          -- hunk 跳转
          map("n", "]h", gs.next_hunk,           "下一个 Git 变更")
          map("n", "[h", gs.prev_hunk,           "上一个 Git 变更")
          -- hunk 操作（统一 <leader>g 前缀）
          map("n", "<leader>gs", gs.stage_hunk,   "暂存当前变更块")
          map("n", "<leader>gr", gs.reset_hunk,   "重置当前变更块")
          map("n", "<leader>gp", gs.preview_hunk, "预览当前变更块")
          map("n", "<leader>gb", gs.blame_line,   "查看行 blame")
        end,
      })
    end,
  },

  -- ── Diffview：全局 diff 视图 + 冲突解决 ───────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",              desc = "打开 Diffview" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>",             desc = "关闭 Diffview" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>",     desc = "当前文件 Git 历史" },
    },
    config = function()
      local actions = require("diffview.actions")

      require("diffview").setup({
        enhanced_diff_hl = true,
        use_icons = true,
        diff_binaries = false,
        file_panel = {
          listing_style = "list",
          win_config = {
            width = 30,
          },
        },
        view = {
          default = { winbar_info = true },
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
        keymaps = {
          -- diff 视图窗口
          view = {
            { "n", "q",  "<cmd>DiffviewClose<cr>", { desc = "关闭 Diffview" } },
            -- do/dp 不覆盖，使用 vim 原生 :diffget/:diffput
            { "n", "]c", actions.next_conflict,     { desc = "下一个冲突" } },
            { "n", "[c", actions.prev_conflict,     { desc = "上一个冲突" } },
          },
          -- 左侧文件面板
          file_panel = {
            { "n", "s", actions.toggle_stage_entry, { desc = "Stage/Unstage 文件" } },
            { "n", "o", actions.select_entry,       { desc = "打开 diff" } },
            { "n", "q", "<cmd>DiffviewClose<cr>",   { desc = "关闭 Diffview" } },
          },
        },
      })
      -- 字符级 diff 算法
      vim.opt.diffopt:append("algorithm:histogram")
      vim.opt.diffopt:append("indent-heuristic")
      vim.opt.diffopt:append("linematch:60")
    end,
  },
}
