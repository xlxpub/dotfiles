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
        -- 光标所在行的行内 blame（常驻显示在行尾，可随时编辑）
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",     -- 显示在行尾
          delay = 400,               -- 光标停留 400ms 后显示
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          -- hunk 跳转
          map("n", "]h", gs.next_hunk,           "[Git] 下一个变更块")
          map("n", "[h", gs.prev_hunk,           "[Git] 上一个变更块")
          -- hunk 操作（统一 <leader>g 前缀）
          map("n", "<leader>gs", gs.stage_hunk,   "[Git] 暂存当前变更块")
          map("n", "<leader>gr", gs.reset_hunk,   "[Git] 重置当前变更块")
          map("n", "<leader>gp", gs.preview_hunk, "[Git] 预览当前变更块")
          map("n", "<leader>gb", gs.blame_line,   "[Git] 查看行 blame（弹窗）")
          -- 变更块范围操作与整文件操作
          map("n", "<leader>gS", gs.stage_buffer, "[Git] 暂存整个文件")
          map("n", "<leader>gR", function() gs.reset_buffer() end, "[Git] 重置整个文件")
          map("n", "<leader>gu", gs.undo_stage_hunk, "[Git] 撤销暂存当前变更块")
          -- 可视化模式下对选中范围操作
          map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "[Git] 暂存选中变更块")
          map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "[Git] 重置选中变更块")
          -- 行内 blame 开关（gitsigns 自带常驻显示，这里手动切换）
          map("n", "<leader>tb", gs.toggle_current_line_blame, "[Git] 切换行内 blame")
          -- 查看当前行 diff 文本
          map("n", "<leader>td", gs.diffthis, "[Git] 查看当前文件 diff")
        end,
      })
    end,
  },

  -- ── Lazygit 已改为普通分屏启动，见 lua/tools/lazygit.lua 与 keymaps.lua ──

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
            -- 冲突解决快捷键
            { "n", "gl", actions.conflict_choose("ours"),   { desc = "选择左边（ours）" } },
            { "n", "gr", actions.conflict_choose("theirs"), { desc = "选择右边（theirs）" } },
            { "n", "gB", actions.conflict_choose("base"),   { desc = "选择 base" } },
            { "n", "ga", actions.conflict_choose("all"),    { desc = "选择全部" } },
            { "n", "gn", actions.conflict_choose("none"),   { desc = "删除冲突标记" } },
            { "n", "gL", actions.conflict_choose_all("ours"),   { desc = "整个文件选择左边（ours）" } },
            { "n", "gR", actions.conflict_choose_all("theirs"), { desc = "整个文件选择右边（theirs）" } },
            { "n", "]x", actions.next_conflict,             { desc = "下一个冲突" } },
            { "n", "[x", actions.prev_conflict,             { desc = "上一个冲突" } },
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
      vim.opt.diffopt:append("followwrap")   -- 长行跟随 wrap 设置换行显示
      vim.opt.diffopt:append("inline:char") -- 行内字符级高亮（nvim 0.11+）

      -- Diffview buffer 打开时注册 which-key 快捷键描述
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "DiffviewFiles", "DiffviewFileHistory", "DiffviewFilePanel" },
        callback = function(args)
          local wk_ok, wk = pcall(require, "which-key")
          if not wk_ok then return end
          wk.add({
            { "]x", desc = "下一个冲突", buffer = args.buf },
            { "[x", desc = "上一个冲突", buffer = args.buf },
            { "gl", desc = "选择左边（ours）", buffer = args.buf },
            { "gr", desc = "选择右边（theirs）", buffer = args.buf },
            { "gB", desc = "选择 base", buffer = args.buf },
            { "ga", desc = "选择全部", buffer = args.buf },
            { "gn", desc = "删除冲突标记", buffer = args.buf },
            { "gL", desc = "整个文件选择左边（ours）", buffer = args.buf },
            { "gR", desc = "整个文件选择右边（theirs）", buffer = args.buf },
            { "s", desc = "Stage/Unstage 文件", buffer = args.buf },
            { "o", desc = "打开 diff", buffer = args.buf },
            { "q", desc = "关闭 Diffview", buffer = args.buf },
          })
        end,
        desc = "Diffview which-key 快捷键提示",
      })
      -- diff buffer（中间窗口）也注册提示
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(args)
          if vim.wo.diff then
            local wk_ok, wk = pcall(require, "which-key")
            if not wk_ok then return end
            wk.add({
              { "]x", desc = "下一个冲突", buffer = args.buf },
              { "[x", desc = "上一个冲突", buffer = args.buf },
              { "gl", desc = "选择左边（ours）", buffer = args.buf },
              { "gr", desc = "选择右边（theirs）", buffer = args.buf },
              { "gB", desc = "选择 base", buffer = args.buf },
              { "ga", desc = "选择全部", buffer = args.buf },
              { "gn", desc = "删除冲突标记", buffer = args.buf },
              { "gL", desc = "整个文件选择左边（ours）", buffer = args.buf },
              { "gR", desc = "整个文件选择右边（theirs）", buffer = args.buf },
              { "q", desc = "关闭 Diffview", buffer = args.buf },
            })
          end
        end,
        desc = "Diff 窗口 which-key 快捷键提示",
      })
    end,
  },

  -- ── Fugitive：:Git 命令全家桶（status / blame / commit / push） ──
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "GitAdd", "GitCommit", "GitBlame" },
    keys = {
      { "<leader>gv", "<cmd>Git<cr>",       desc = "[Git] :Git 状态面板" },
      { "<leader>gB", "<cmd>Git blame<cr>", desc = "[Git] 当前文件 blame" },
    },
  },
}
