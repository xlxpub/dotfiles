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
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

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
				pickers = {
					find_files = {
						hidden = true, -- 包含隐藏文件
						find_command = {
							"fd",
							"--type",
							"f",
							"--hidden",
							"--no-ignore",
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
						},
					},
					live_grep = {
						additional_args = function()
							-- 让 rg 也不遵守 .gitignore 并搜索隐藏文件
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
							}
						end,
					},
					grep_string = {
						additional_args = function()
							return {
								"--hidden",
								"--no-ignore",
								"--glob=!.git/*",
								"--glob=!node_modules/*",
							}
						end,
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("yank_history") -- 加载 yanky 扩展

			-- 用 <leader>y 打开 yank 历史面板
			vim.keymap.set("n", "<leader>y", "<cmd>Telescope yank_history<cr>", { desc = "Yank 历史" })
		end,
	},
}
