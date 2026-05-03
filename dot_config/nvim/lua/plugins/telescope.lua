return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				-- C 扩展加速排序
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			"gbprod/yanky.nvim", -- yank 历史扩展依赖
			"nvim-telescope/telescope-live-grep-args.nvim", -- 支持在搜索框传 rg 参数
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local lga_actions = require("telescope-live-grep-args.actions")

			telescope.setup({
				defaults = {
					prompt_prefix = "  ",
					selection_caret = " ",
					path_display = { "truncate" },
					-- 禁用 treesitter 预览高亮（nvim 0.12 移除了 ft_to_lang，会报错）
					preview = {
						treesitter = false,
					},
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<Esc>"] = actions.close,
						},
					},
				},
				extensions = {
					live_grep_args = {
						auto_quoting = true, -- 关键词有空格时自动加引号
						mappings = {
							i = {
								-- <C-k> 在关键词两端加引号（用于含空格的词）
								["<C-k>"] = lga_actions.quote_prompt(),
								-- <C-i> 追加 --iglob（快速限定文件类型/目录）
								["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
							},
						},
						additional_args = {
							"--hidden",
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
						},
					},
				},
				pickers = {
					find_files = {
						hidden = true, -- 包含隐藏文件
						-- 说明：不再加 --no-ignore，让 fd 默认遵守 .gitignore（项目级）
						-- 及 ~/.config/fd/ignore（全局级）。下面 --exclude 仅作为兜底，
						-- 用于即使项目没配置 gitignore 也强制排除的常见目录。
						find_command = {
							"fd",
							"--type",
							"f",
							"--hidden",
							"--strip-cwd-prefix",
							"--exclude",
							".git",
							"--exclude",
							".idea",
							"--exclude",
							".vscode",
							"--exclude",
							"node_modules",
							"--exclude",
							".cache",
							"--exclude",
							"dist",
							"--exclude",
							"build",
							"--exclude",
							".DS_Store",
							"--exclude",
							".venv",
							"--exclude",
							"venv",
							"--exclude",
							"__pycache__",
						},
					},
					live_grep = {
						additional_args = function()
							-- 不再加 --no-ignore，让 rg 遵守 .gitignore
							-- 仅保留 --hidden 搜索隐藏文件 + glob 兜底排除
							return {
								"--hidden",
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
					},
					grep_string = {
						additional_args = function()
							return {
								"--hidden",
								"--glob=!.git/*",
								"--glob=!node_modules/*",
								"--glob=!.venv/*",
								"--glob=!venv/*",
							}
						end,
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("yank_history") -- 加载 yanky 扩展
			telescope.load_extension("live_grep_args") -- 加载 live_grep_args 扩展

			-- 用 <leader>y 打开 yank 历史面板
			vim.keymap.set("n", "<leader>y", "<cmd>Telescope yank_history<cr>", { desc = "Yank 历史" })
		end,
	},
}
