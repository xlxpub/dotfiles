-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  JSON 中 markdown 字段预览工具
--
--  使用场景：JSON 某个字段的值是 markdown 字符串（含 \n \t 等转义），
--  光标放在该字符串字面量上按快捷键，即可把反转义后的内容取出来渲染。
--
--  键位（见 keymaps.lua 末尾）：
--    <leader>mj  → 在新 buffer 渲染为 markdown
--    <leader>mJ  → 渲染 + 浏览器预览（调 MarkdownPreview）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}

---获取光标所在的 JSON 字符串字面量，并还原为 Lua 字符串
---优先用 treesitter（精准）；失败时回退到正则
---@return string|nil content 解析后的原始字符串
local function get_json_string_at_cursor()
	-- 方案 A：treesitter（最准）
	local ok_ts, ts = pcall(require, "vim.treesitter")
	if ok_ts then
		-- 先确保 parser 已解析（headless / 刚打开时 get_node 会为 nil）
		pcall(function()
			local parser = ts.get_parser(0, "json")
			if parser then parser:parse(true) end
		end)

		local cur = vim.api.nvim_win_get_cursor(0) -- {row(1-based), col(0-based)}
		local ok_parser, node = pcall(ts.get_node, { pos = { cur[1] - 1, cur[2] } })
		if ok_parser and node then
			-- 向上找最近的 string 节点
			local n = node
			while n do
				local ntype = n:type()
				if ntype == "string" or ntype == "string_content" then
					-- 拿到包含引号的完整字面量
					if ntype == "string_content" then
						n = n:parent() or n
					end
					local raw = ts.get_node_text(n, 0)
					-- raw 形如 "..."，用 vim.json.decode 反转义
					local ok_json, decoded = pcall(vim.json.decode, raw)
					if ok_json and type(decoded) == "string" then
						return decoded
					end
					return raw
				end
				n = n:parent()
			end
		end
	end

	-- 方案 B：回退——取当前行，按冒号后的引号串切出字符串字面量
	local line = vim.api.nvim_get_current_line()
	-- "key": "value",  →  提取后面那段 "value"（含可能的转义）
	local quoted = line:match(':%s*(".*")%s*,?%s*$')
	if not quoted then
		-- 整行是字符串值（数组元素等）
		quoted = line:match('^%s*(".*")%s*,?%s*$')
	end
	if quoted then
		local ok_json, decoded = pcall(vim.json.decode, quoted)
		if ok_json and type(decoded) == "string" then
			return decoded
		end
	end
	return nil
end

---把内容写到一个 scratch buffer 并打开
---若已有同名预览 buffer 则复用（避免 E95 / 多窗口堆叠）
---@param content string
---@return integer bufnr
local function open_in_scratch(content)
	local preview_name = "[JSON-MD Preview]"

	-- 找已有的预览 buffer（按完整路径匹配，nvim 把名字存为绝对路径）
	local existing_buf = nil
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(b) then
			local name = vim.api.nvim_buf_get_name(b)
			if name:match(vim.pesc(preview_name) .. "$") then
				existing_buf = b
				break
			end
		end
	end

	local buf, win
	if existing_buf then
		-- 复用：如果已经有窗口显示，就切过去；否则在右侧重新打开
		local wins = vim.fn.win_findbuf(existing_buf)
		if #wins > 0 then
			vim.api.nvim_set_current_win(wins[1])
			win = wins[1]
		else
			vim.cmd("botright vsplit")
			vim.api.nvim_set_current_buf(existing_buf)
			win = vim.api.nvim_get_current_win()
		end
		buf = existing_buf
		-- 清空旧内容（buffer 是 nofile 可以直接改）
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
	else
		-- 新建预览窗
		vim.cmd("botright vnew")
		buf = vim.api.nvim_get_current_buf()
		win = vim.api.nvim_get_current_win()
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide" -- 改为 hide，关窗不销毁 buffer，下次可复用
		vim.bo[buf].swapfile = false
		vim.bo[buf].filetype = "markdown"
		vim.api.nvim_buf_set_name(buf, preview_name)
		-- q 快速关闭窗口（不销毁 buffer，保留给下次复用）
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "关闭预览窗" })
	end

	-- 自动软换行：超出窗口宽度时折行显示，而不是横向滚动
	vim.wo[win].wrap = true          -- 启用软换行
	vim.wo[win].linebreak = true     -- 在单词边界换行（不把单词从中间切开）
	vim.wo[win].breakindent = true   -- 折行时对齐原缩进，列表 / 代码缩进不错位
	vim.wo[win].showbreak = "↪ "     -- 折行续行前缀，一眼看出是续行不是新段
	vim.wo[win].number = false       -- 预览窗不显示行号，省空间
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"

	local lines = vim.split(content, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	-- 光标回到顶部
	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	return buf
end

---主命令：在 scratch buffer 渲染
function M.preview()
	local content = get_json_string_at_cursor()
	if not content then
		vim.notify("未能识别光标所在的 JSON 字符串字段", vim.log.levels.WARN)
		return
	end
	open_in_scratch(content)
end

---主命令：渲染 + 调 MarkdownPreview 用浏览器打开
function M.preview_browser()
	local content = get_json_string_at_cursor()
	if not content then
		vim.notify("未能识别光标所在的 JSON 字符串字段", vim.log.levels.WARN)
		return
	end
	open_in_scratch(content)
	-- 给 markdown-preview.nvim 一点时间接管 buffer
	vim.defer_fn(function()
		local ok = pcall(vim.cmd, "MarkdownPreview")
		if not ok then
			vim.notify("MarkdownPreview 未安装或加载失败", vim.log.levels.WARN)
		end
	end, 100)
end

return M
