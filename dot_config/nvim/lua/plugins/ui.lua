return {
	-- ── 主题：github-nvim-theme（GitHub 官方配色）──
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = false,
		priority = 1000, -- 最先加载
		config = function()
			vim.opt.background = "dark"
			require("github-theme").setup({
				options = {
					transparent = false,
					hide_end_of_buffer = true,
					hide_nc_statusline = true,
					styles = {
						comments = "italic",
						keywords = "NONE",
						functions = "NONE",
						variables = "NONE",
					},
				},
				-- 自定义高亮：diff 用 GitHub 风格更鲜明的配色
				specs = {
					all = {
						syntax = {},
					},
				},
			})
			vim.cmd("colorscheme github_dark_dimmed")

			-- 加载主题后再覆盖 diff 高亮（必须在 colorscheme 之后）
			local function set_diff_hl()
				-- GitHub Dark Dimmed 风格 diff 色：暗底 + 对比鲜明的字符级高亮
				-- 行级背景（整行高亮）
				vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#0d3620", fg = "NONE" })
				vim.api.nvim_set_hl(0, "DiffChange", { bg = "#0a3069", fg = "NONE" })
				vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#3c1618", fg = "#f85149" })
				-- 字符级高亮（必须比行级底色更亮、对比更强）
				vim.api.nvim_set_hl(0, "DiffText", { bg = "#1f6feb", fg = "#ffffff", bold = true })
				-- diffview.nvim 专用（行级）
				vim.api.nvim_set_hl(0, "DiffviewDiffAdd", { bg = "#0d3620", fg = "NONE" })
				vim.api.nvim_set_hl(0, "DiffviewDiffChange", { bg = "#0a3069", fg = "NONE" })
				vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { fg = "#484f58", bg = "NONE" })
				vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = "#3c1618", fg = "NONE" })
				-- diffview.nvim 专用（字符级，左右分别用红绿醒目突出）
				vim.api.nvim_set_hl(0, "DiffviewDiffText", { bg = "#1f6feb", fg = "#ffffff", bold = true })
				vim.api.nvim_set_hl(0, "DiffviewDiffAddText", { bg = "#238636", fg = "#ffffff", bold = true })
				vim.api.nvim_set_hl(0, "DiffviewDiffDeleteText", { bg = "#da3633", fg = "#ffffff", bold = true })
				-- 搜索高亮
				vim.api.nvim_set_hl(0, "Search", { bg = "#9e6a03", fg = "#f0f6fc", bold = true })
				vim.api.nvim_set_hl(0, "IncSearch", { bg = "#fd8c73", fg = "#0d1117", bold = true })
			end
			set_diff_hl()
			-- 再次切主题时也保持这些覆盖
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "github_*",
				callback = set_diff_hl,
			})
		end,
	},

	-- ── 状态栏：lualine ───────────────────────────
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "github_dark_dimmed",
					component_separators = "|",
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } }, -- 显示相对路径
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- ── 文件树：nvim-tree ─────────────────────────
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- 禁用 netrw（nvim-tree 替代它）
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			require("nvim-tree").setup({
				view = { width = 30 },
				renderer = {
					group_empty = true, -- 空目录合并显示
					icons = {
						show = {
							file = true, -- 显示文件符号
							folder = true, -- 显示文件夹符号
							folder_arrow = true, -- 显示文件夹箭头
							git = true, -- 显示 git 状态符号
						},
						glyphs = {
							default = "",
							symlink = "",
							folder = {
								arrow_closed = "", -- 折叠时的箭头
								arrow_open = "", -- 展开时的箭头
								default = "", -- 文件夹符号
								open = "", -- 打开的文件夹符号
								empty = "", -- 空文件夹符号
								empty_open = "", -- 打开的空文件夹符号
								symlink = "", -- 符号链接文件夹
								symlink_open = "",
							},
							git = {
								untracked = "?", -- 未跟踪：问号
								unstaged = "M", -- 已修改：M
								staged = "✓", -- 已暂存：对勾
								deleted = "D", -- 已删除：D
							},
						},
					},
				},
				filters = {
					dotfiles = false, -- 显示隐藏文件
					custom = { "^.git$" }, -- 只过滤 .git（不过滤 .omc）
				},
				-- 自动跟随当前文件：切换 buffer 时文件树自动定位
				update_focused_file = {
					enable = true,
					update_root = false, -- 根目录也跟随切换
				},
			})
		end,
	},

	-- ── 标签页：bufferline ────────────────────────
	{
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					diagnostics = "nvim_lsp", -- 标签页上显示 LSP 诊断
					offsets = {
						{
							filetype = "NvimTree",
							text = "文件树",
							highlight = "Directory",
							separator = true,
						},
					},
				},
			})
		end,
	},

	-- ── 开始界面：alpha-nvim ──────────────────────
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local dashboard = require("alpha.themes.dashboard")
			dashboard.section.buttons.val = {
				dashboard.button("f", "  查找文件", "<cmd>Telescope find_files<cr>"),
				dashboard.button("r", "  最近文件", "<cmd>Telescope oldfiles<cr>"),
				dashboard.button("g", "  全文搜索", "<cmd>Telescope live_grep<cr>"),
				dashboard.button("e", "  文件树", "<cmd>NvimTreeToggle<cr>"),
				dashboard.button("q", "  退出", "<cmd>qa<cr>"),
			}
			require("alpha").setup(dashboard.config)
		end,
	},

	-- ── 缩进线 ────────────────────────────────────
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({ indent = { char = "▏" } })
		end,
	},

	-- ── 颜色代码预览 ──────────────────────────────
	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},

	-- ── 符号大纲：aerial.nvim ─────────────────────
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>a", "<cmd>AerialToggle<cr>", desc = "大纲面板 开关" },
			{ "[a", "<cmd>AerialPrev<cr>", desc = "上一个符号" },
			{ "]a", "<cmd>AerialNext<cr>", desc = "下一个符号" },
			{ "<leader>fa", "<cmd>Telescope aerial<cr>", desc = "Telescope 符号搜索" },
		},
		config = function()
			require("aerial").setup({
				-- 优先使用 LSP，回退到 treesitter
				backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
				layout = {
					max_width = { 40, 0.2 }, -- 最大宽度 40 列或 20%
					min_width = 20,
					default_direction = "right", -- 显示在右侧
				},
				-- 跟随光标自动高亮当前符号
				highlight_on_hover = true,
				-- 在 winbar 显示当前所在符号路径（面包屑，替代 lspsaga 的 symbol_in_winbar）
				attach_mode = "window",
				show_guides = true,
				-- 关闭时自动收起
				autojump = false,
				-- 在 lualine 显示当前符号（可选）
				lualine_min_width = 10,
			})
			-- 注册 Telescope 扩展
			require("telescope").load_extension("aerial")
			-- winbar 显示符号面包屑（仅在有 LSP 附加的 buffer 生效）
			-- 自定义 winbar 函数，替代已废弃的 fmt_winbar
			_G._aerial_winbar = function()
				local ok, aerial = pcall(require, "aerial")
				if not ok then
					return ""
				end
				local loc = aerial.get_location(true)
				if not loc or #loc == 0 then
					return ""
				end
				local parts = {}
				for _, item in ipairs(loc) do
					table.insert(parts, item.icon .. " " .. item.name)
				end
				return table.concat(parts, " > ")
			end
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function()
					vim.api.nvim_set_option_value(
						"winbar",
						"%{%v:lua._aerial_winbar()%}",
						{ scope = "local", win = vim.api.nvim_get_current_win() }
					)
				end,
			})
		end,
	},
}
