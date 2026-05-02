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
---@param opts? { filetype?: string, buf_name?: string }
---@return integer bufnr
local function open_in_scratch(content, opts)
	opts = opts or {}
	local ft = opts.filetype or "markdown"
	local preview_name_override = opts.buf_name
	local preview_name = preview_name_override or "[JSON-MD Preview]"

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

	local src_win = vim.api.nvim_get_current_win() -- 记住源文件窗口
	local buf, win
	if existing_buf then
		-- 复用：如果已经有窗口显示，直接更新内容；否则在右侧重新打开
		local wins = vim.fn.win_findbuf(existing_buf)
		if #wins > 0 then
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
		-- 复用时也更新 filetype（Markdown/JSON 预览可能交替使用）
		vim.bo[buf].filetype = ft
	else
		-- 新建预览窗
		vim.cmd("botright vnew")
		buf = vim.api.nvim_get_current_buf()
		win = vim.api.nvim_get_current_win()
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide" -- 改为 hide，关窗不销毁 buffer，下次可复用
		vim.bo[buf].swapfile = false
		vim.bo[buf].filetype = ft
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
	-- 预览窗光标回到顶部
	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	-- 焦点还回源文件窗口，方便连续预览不同字段
	vim.api.nvim_set_current_win(src_win)
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

---把 Lua 表格式化为带缩进的 JSON 字符串
---@param value any  vim.json.decode 返回的 Lua 值
---@param indent? integer 当前缩进层级
---@return string
local function json_pretty(value, indent)
	indent = indent or 0
	local t = type(value)
	if t == "nil" or value == vim.NIL then
		return "null"
	elseif t == "boolean" or t == "number" then
		return tostring(value)
	elseif t == "string" then
		return vim.json.encode(value)
	elseif t == "table" then
		-- 判断是数组还是对象
		local is_array = vim.islist(value)
		if is_array then
			if #value == 0 then return "[]" end
			local items = {}
			for _, v in ipairs(value) do
				table.insert(items, string.rep("  ", indent + 1) .. json_pretty(v, indent + 1))
			end
			return "[\n" .. table.concat(items, ",\n") .. "\n" .. string.rep("  ", indent) .. "]"
		else
			local keys = {}
			for k in pairs(value) do table.insert(keys, k) end
			if #keys == 0 then return "{}" end
			table.sort(keys)
			local items = {}
			for _, k in ipairs(keys) do
				local kstr = vim.json.encode(k)
				table.insert(items, string.rep("  ", indent + 1) .. kstr .. ": " .. json_pretty(value[k], indent + 1))
			end
			return "{\n" .. table.concat(items, ",\n") .. "\n" .. string.rep("  ", indent) .. "}"
		end
	end
	return tostring(value)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  日志行 JSON 提取
--
--  使用场景：日志行中直接嵌入多个 JSON 对象，如：
--    2026-01-01 ERROR {"id":"1","msg":"xx"} {"reqid":"abc"}
--  光标放在任意一个 JSON 对象内部，提取该完整 JSON 并格式化预览。
--
--  键位：<leader>jel（json extract from log line）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---扫描字符串，返回所有顶层 {…} 块的 [start, end]（1-based Lua 索引）
---@param line string
---@return {s:integer, e:integer}[]
local function find_json_spans(line)
	local spans = {}
	local depth = 0
	local start_pos = nil
	local i = 1
	while i <= #line do
		local ch = line:sub(i, i)
		-- 跳过字符串字面量，避免把字符串里的 {} 误判为括号
		if ch == '"' then
			i = i + 1
			while i <= #line do
				local c = line:sub(i, i)
				if c == '\\' then
					i = i + 2 -- 跳过转义字符
				elseif c == '"' then
					i = i + 1
					break
				else
					i = i + 1
				end
			end
		elseif ch == '{' then
			depth = depth + 1
			if depth == 1 then start_pos = i end
			i = i + 1
		elseif ch == '}' then
			depth = depth - 1
			if depth == 0 and start_pos then
				table.insert(spans, { s = start_pos, e = i })
				start_pos = nil
			end
			i = i + 1
		else
			i = i + 1
		end
	end
	return spans
end

---内部辅助：从日志行提取光标处 JSON，返回格式化字符串和 span，失败返回 nil
---@return string|nil formatted, {s:integer,e:integer}|nil span
local function _get_log_json_formatted()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 转为 1-based

	local spans = find_json_spans(line)
	if #spans == 0 then
		vim.notify("当前行未找到 JSON 对象", vim.log.levels.WARN)
		return nil, nil
	end

	local target = nil
	for _, sp in ipairs(spans) do
		if col >= sp.s and col <= sp.e then
			target = sp
			break
		end
	end

	if not target then
		local hints = {}
		for idx, sp in ipairs(spans) do
			table.insert(hints, string.format("  [%d] col %d-%d: %s", idx, sp.s, sp.e,
				line:sub(sp.s, math.min(sp.e, sp.s + 40)) .. (sp.e - sp.s > 40 and "…" or "")))
		end
		vim.notify("光标不在任何 JSON 对象内。行内 JSON 块：\n" .. table.concat(hints, "\n"), vim.log.levels.WARN)
		return nil, nil
	end

	local json_str = line:sub(target.s, target.e)
	local ok, decoded = pcall(vim.json.decode, json_str)
	if not ok then
		vim.notify("提取到的内容不是合法 JSON：\n" .. json_str, vim.log.levels.WARN)
		return nil, nil
	end

	return json_pretty(decoded), target
end

---主命令：从日志行提取光标所在的 JSON 对象并格式化预览
function M.extract_log_json()
	local formatted, target = _get_log_json_formatted()
	if not formatted or not target then return end
	open_in_scratch(formatted, { filetype = "json", buf_name = "[Log JSON]" })
	vim.notify(string.format("已提取 col %d-%d 的 JSON", target.s, target.e))
end

---主命令：从日志行提取 JSON 并复制到系统剪切板（寄存器 +）
function M.extract_log_json_yank()
	local formatted, target = _get_log_json_formatted()
	if not formatted or not target then return end
	vim.fn.setreg("+", formatted)   -- 写入系统剪切板
	vim.notify(string.format("已复制 col %d-%d 的 JSON 到剪切板（%d 字节）",
		target.s, target.e, #formatted))
end

---主命令：从日志行提取 JSON 并写入外部文件
---会弹出输入框让用户确认/修改路径，默认写到 /tmp/extracted.json
function M.extract_log_json_write()
	local formatted, target = _get_log_json_formatted()
	if not formatted or not target then return end

	local default_path = "/tmp/extracted.json"
	vim.ui.input({ prompt = "写入文件路径: ", default = default_path }, function(path)
		if not path or path == "" then
			vim.notify("已取消写入", vim.log.levels.INFO)
			return
		end
		-- 展开 ~ 和环境变量
		path = vim.fn.expand(path)
		local f, err = io.open(path, "w")
		if not f then
			vim.notify("无法写入文件: " .. (err or path), vim.log.levels.ERROR)
			return
		end
		f:write(formatted)
		f:write("\n")
		f:close()
		vim.notify(string.format("已写入 %s（col %d-%d，%d 字节）", path, target.s, target.e, #formatted))
	end)
end

---主命令：提取光标处 JSON 字符串值，尝试解析并格式化为 JSON 预览
function M.preview_json()
	local content = get_json_string_at_cursor()
	if not content then
		vim.notify("未能识别光标所在的 JSON 字符串字段", vim.log.levels.WARN)
		return
	end
	-- 尝试把提取到的字符串当作 JSON 解析
	local ok, decoded = pcall(vim.json.decode, content)
	if not ok then
		vim.notify("该字段值不是有效 JSON：" .. tostring(decoded), vim.log.levels.WARN)
		return
	end
	local formatted = json_pretty(decoded)
	open_in_scratch(formatted, { filetype = "json", buf_name = "[JSON Preview]" })
end

return M
