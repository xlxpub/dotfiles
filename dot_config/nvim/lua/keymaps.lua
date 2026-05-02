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
map("n", "<leader>rl", "<cmd>checktime<cr>",       { desc = "检查并重载所有外部修改" })
map("n", "<leader>rL", "<cmd>e!<cr>",              { desc = "强制重载当前文件（丢弃本地改动）" })

-- 清除搜索高亮
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "清除高亮" })

-- 强制重绘屏幕（修复终端渲染异常 / 蓝屏）
map({ "n", "t" }, "<C-S-l>", "<cmd>mode<cr>", { desc = "强制重绘屏幕" })

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

-- 终端模式下也能直接用 Ctrl+hjkl 切换窗口（无需先按 Ctrl+\ Ctrl+n）

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
-- 临时搜索 gitignored 文件（加 --no-ignore 绕过 .gitignore）
map("n", "<leader>fF", function()
	require("telescope.builtin").find_files({
		hidden = true,
		find_command = {
			"fd", "--type", "f", "--hidden", "--no-ignore", "--strip-cwd-prefix",
			"--exclude", ".git",
			"--exclude", ".idea",
			"--exclude", ".vscode",
		},
		prompt_title = "查找文件（含 gitignored）",
	})
end, { desc = "查找文件（含 gitignored）" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   { desc = "全文搜索" })
-- 全文搜索（含 gitignored，加 --no-ignore 绕过 .gitignore）
map("n", "<leader>fG", function()
	require("telescope.builtin").live_grep({
		additional_args = function()
			return {
				"--hidden",
				"--no-ignore",
				"--glob=!.git/*",
				"--glob=!.idea/*",
				"--glob=!.vscode/*",
				"--glob=!node_modules/*",
				"--glob=!.cache/*",
				"--glob=!dist/*",
				"--glob=!build/*",
				"--glob=!.venv/*",
				"--glob=!venv/*",
				"--glob=!__pycache__/*",
			}
		end,
		prompt_title = "全文搜索（含 gitignored）",
	})
end, { desc = "全文搜索（含 gitignored）" })
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
--  拷贝文件路径 / 行号
-- ══════════════════════════════
-- 相对路径（最常用，用于代码 review / 粘贴给别人）
map("n", "<leader>pp", '<cmd>let @+=expand("%")<cr>',            { desc = "复制：相对路径" })
-- 绝对路径
map("n", "<leader>pP", '<cmd>let @+=expand("%:p")<cr>',          { desc = "复制：绝对路径" })
-- 文件名（不含目录）
map("n", "<leader>pn", '<cmd>let @+=expand("%:t")<cr>',          { desc = "复制：文件名" })
-- 相对路径 + 行号（如 lua/keymaps.lua:42）
map("n", "<leader>pl", function()
  vim.fn.setreg("+", vim.fn.expand("%") .. ":" .. vim.fn.line("."))
end, { desc = "复制：相对路径:行号" })
-- 函数名（treesitter，光标在函数体内任意位置均有效）
-- 复制格式：相对路径:函数名（如 tools/search_schedule.go:SearchSchedule）
map("n", "<leader>pf", function()
	local bufnr = vim.api.nvim_get_current_buf()
	-- 确保 treesitter parser 已启动
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		vim.notify("treesitter parser 未加载（当前文件类型可能不支持）", vim.log.levels.WARN)
		return
	end
	-- 强制解析一次，确保语法树就绪
	parser:parse()

	local node = vim.treesitter.get_node()
	if not node then
		vim.notify("无法获取光标处的语法节点", vim.log.levels.WARN)
		return
	end
	local func_types = {
		function_declaration = true, method_declaration = true,  -- Go / C
		function_definition  = true, local_function = true,      -- Lua / Python
		method_definition    = true, arrow_function = true,      -- JS / TS
	}
	local cur = node
	while cur do
		if func_types[cur:type()] then
			local name_node = cur:field("name")[1]
			if name_node then
				local name = vim.treesitter.get_node_text(name_node, 0)
				local result = vim.fn.expand("%") .. ":" .. name
				vim.fn.setreg("+", result)
				vim.notify("已复制：" .. result)
				return
			end
		end
		cur = cur:parent()
	end
	vim.notify("未找到函数名（光标需在函数体内）", vim.log.levels.WARN)
end, { desc = "复制：相对路径:函数名" })


-- 整个文件格式化
map("n", "<leader>jf", "<cmd>%!jq .<cr>", { desc = "JSON 格式化（整个文件）" })
-- 可视模式：只格式化选中部分
map("v", "<leader>jf", ":'<,'>!jq .<cr>", { desc = "JSON 格式化（选中区域）" })
-- 压缩为单行（minify）
map("n", "<leader>jm", "<cmd>%!jq -c .<cr>", { desc = "JSON 压缩为单行" })

-- ══════════════════════════════
--  JSON 内嵌字段提取预览（je = Json Extract）
--  光标放在 JSON 字符串值上，提取并反转义后渲染
-- ══════════════════════════════
map("n", "<leader>jej", function() require("tools.json_md_preview").preview_json() end,
	{ desc = "提取 JSON 中的 JSON 字符串（格式化预览）" })
map("n", "<leader>jel", function() require("tools.json_md_preview").extract_log_json() end,
	{ desc = "提取日志行中光标所在的 JSON 对象" })
map("n", "<leader>jem", function() require("tools.json_md_preview").preview() end,
	{ desc = "提取 JSON 中的 Markdown（buffer 预览）" })
map("n", "<leader>jeM", function() require("tools.json_md_preview").preview_browser() end,
	{ desc = "提取 JSON 中的 Markdown（浏览器预览）" })
