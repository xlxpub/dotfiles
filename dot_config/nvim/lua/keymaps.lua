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

-- 重载文件（外部编辑器/Claude 修改后手动同步）
map("n", "<leader>e", "<cmd>checktime<cr>",       { desc = "检查并重载所有外部修改" })
map("n", "<leader>E", "<cmd>e!<cr>",              { desc = "强制重载当前文件（丢弃本地改动）" })

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
map("n", "<leader>e",  "<cmd>NvimTreeToggle<cr>",       { desc = "文件树开关" })
map("n", "<leader>E",  "<cmd>NvimTreeFindFile<cr>",     { desc = "文件树定位当前文件" })

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

-- ══════════════════════════════
--  Git 冲突解决（Diffview）
-- ══════════════════════════════
-- 使用场景：`git merge` 产生冲突后 → :DiffviewOpen（或 <leader>gd）
-- 左=OURS(本地)  中=结果(要编辑的文件)  右=THEIRS(远程)
-- ⚠️ 必须先在左侧 FilePanel 按回车打开有冲突的文件，
--    把光标放到【中间】窗口的冲突块里，再按下面的键。

-- 用 diffview 自己的 action API，兼容其合并视图
local function conflict_choose(side)
  return function()
    local ok, actions = pcall(require, "diffview.actions")
    if ok and actions.conflict_choose then
      actions.conflict_choose(side)()
    else
      vim.notify("diffview.nvim 未加载或不在合并视图", vim.log.levels.WARN)
    end
  end
end

map("n", "<leader>gl", conflict_choose("ours"),   { desc = "冲突：选择本地版本 (OURS)" })
map("n", "<leader>gR", conflict_choose("theirs"), { desc = "冲突：选择远程版本 (THEIRS)" })
map("n", "<leader>gB", conflict_choose("base"),   { desc = "冲突：选择共同祖先 (BASE)" })
map("n", "<leader>gA", conflict_choose("all"),    { desc = "冲突：保留全部三方" })
map("n", "<leader>gX", conflict_choose("none"),   { desc = "冲突：删除整个冲突块" })
map("n", "<leader>gb", "<cmd>e!<cr>",             { desc = "放弃修改重载文件（应急）" })

-- 冲突块之间跳转
map("n", "]x", "/<<<<<<<<cr>", { desc = "跳到下一个冲突块" })
map("n", "[x", "?<<<<<<<<cr>", { desc = "跳到上一个冲突块" })

-- ══════════════════════════════
--  JSON 内嵌字段提取预览（je = Json Extract）
--  光标放在 JSON 字符串值上，提取并反转义后渲染
-- ══════════════════════════════
map("n", "<leader>jej", function() require("tools.json_md_preview").preview_json() end,
	{ desc = "提取 JSON 中的 JSON 字符串（格式化预览）" })
map("n", "<leader>jem", function() require("tools.json_md_preview").preview() end,
	{ desc = "提取 JSON 中的 Markdown（buffer 预览）" })
map("n", "<leader>jeM", function() require("tools.json_md_preview").preview_browser() end,
	{ desc = "提取 JSON 中的 Markdown（浏览器预览）" })
