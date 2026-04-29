return {
	-- ── snacks.nvim（claudecode.nvim 依赖）────────────────
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- 只启用需要的模块，其余关闭避免干扰现有配置
			terminal = { enabled = true },
			bigfile = { enabled = false },
			dashboard = {
				enabled = true,
				preset = {
					keys = {
						{ icon = " ", key = "f", desc = "查找文件", action = "<cmd>Telescope find_files<cr>" },
						{ icon = " ", key = "r", desc = "最近文件", action = "<cmd>Telescope oldfiles<cr>" },
						{ icon = " ", key = "g", desc = "全文搜索", action = "<cmd>Telescope live_grep<cr>" },
						{ icon = " ", key = "e", desc = "文件树",   action = "<cmd>NvimTreeToggle<cr>" },
						{ icon = " ", key = "l", desc = "插件管理", action = "<cmd>Lazy<cr>" },
						{ icon = " ", key = "q", desc = "退出",     action = "<cmd>qa<cr>" },
					},
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
			notifier = { enabled = false },
			quickfile = { enabled = false },
			statuscolumn = { enabled = false },
			words = { enabled = false },
		},
	},

	-- ── snacks 终端快捷键（全局可用）─────────────────────
	{
		"folke/snacks.nvim",
		keys = {
			-- 底部分屏终端（日常跑命令用）
			{ "<leader>tt", function() Snacks.terminal.toggle() end,          desc = "终端：底部开关" },
			-- 浮动终端
			{ "<leader>tf", function() Snacks.terminal.toggle(nil, { win = { style = "float" } }) end, desc = "终端：浮动开关" },
		},
	},

	-- ── claudecode.nvim ───────────────────────────────────
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		opts = {
			auto_start = true,      -- nvim 启动时自动开启 WebSocket 服务
			track_selection = true, -- 自动同步选区给 Claude
			-- terminal_cmd 不设置，自动从 PATH 查找 claude
			terminal = {
				split_side = "right",
				split_width_percentage = 0.35,
				provider = "snacks", -- 使用 snacks 终端
				auto_close = true,   -- 退出 claude 后自动关闭终端
			},
			diff_opts = {
				layout = "vertical",     -- 左右分栏 diff
				open_in_new_tab = false,
				keep_terminal_focus = false,
			},
		},
		-- <leader>c 前缀（c = Claude）
		-- 注意：<leader>ca/ci/co 已被 LSP 占用，跳过这三个
		keys = {
			{ "<leader>cc", "<cmd>ClaudeCode<cr>",            desc = "Claude: 开关面板" },
			{ "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Claude: 聚焦面板" },
			{ "<leader>cr", "<cmd>ClaudeCode --resume<cr>",   desc = "Claude: 恢复会话" },
			{ "<leader>cC", "<cmd>ClaudeCode --continue<cr>",   desc = "Claude: continue会话" },
			{ "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Claude: 添加当前文件" },
			{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>",        mode = "v", desc = "Claude: 发送选中内容" },
			{ "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Claude: 接受 diff（yes）" },
			{ "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Claude: 拒绝 diff（no）" },
		},
	},
}
