return {
	-- ── snacks.nvim ────────────────
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
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
			{ "<leader>tt", function() Snacks.terminal.toggle() end,          desc = "终端：底部开关" },
			{ "<leader>tf", function() Snacks.terminal.toggle(nil, { win = { style = "float" } }) end, desc = "终端：浮动开关" },
		},
	},
}
