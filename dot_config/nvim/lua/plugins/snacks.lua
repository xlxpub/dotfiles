return {
	-- ── snacks.nvim（claudecode.nvim 依赖）────────────────
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- 只启用需要的模块，其余关闭避免干扰现有配置
			terminal = {
				enabled = true,
				win = {
					wo = { winblend = 0 },
					backdrop = false, -- 关闭背景遮罩层
				},
			},
			bigfile = { enabled = false },
			dashboard = {
				enabled = true,
				preset = {
					keys = {
						{ icon = " ", key = "f", desc = "查找文件", action = "<cmd>Telescope find_files<cr>" },
						{ icon = " ", key = "r", desc = "最近文件", action = "<cmd>Telescope oldfiles<cr>" },
						{ icon = " ", key = "g", desc = "全文搜索", action = "<cmd>Telescope live_grep_args<cr>" },
						{ icon = " ", key = "e", desc = "文件树", action = "<cmd>NvimTreeToggle<cr>" },
						{ icon = " ", key = "l", desc = "插件管理", action = "<cmd>Lazy<cr>" },
						{ icon = " ", key = "q", desc = "退出", action = "<cmd>qa<cr>" },
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
			{
				"<leader>tt",
				function()
					-- 打开终端前先关闭 Claude 窗口
					require("tools.terminal_exclusive").hide_claude()
					Snacks.terminal.toggle()
					vim.cmd("mode") -- 强制重绘屏幕，清除终端渲染残留
				end,
				desc = "终端：底部开关",
			},
			-- 浮动终端
			{
				"<leader>tf",
				function()
					-- 打开终端前先关闭 Claude 窗口
					require("tools.terminal_exclusive").hide_claude()
					Snacks.terminal.toggle(nil, { win = { style = "float" } })
					vim.cmd("mode")
				end,
				desc = "终端：浮动开关",
			},
			{
				"<C-.>",
				function()
					-- 打开终端前先关闭 Claude 窗口
					require("tools.terminal_exclusive").hide_claude()
					Snacks.terminal.toggle()
				end,
				mode = { "n", "t" },  -- t = TERMINAL 模式
				desc = "终端：toggle（普通/终端模式均可）",
			},
		},
	},
}
