local opt = vim.opt

-- 行号
opt.number = true           -- 显示行号
opt.relativenumber = true   -- 相对行号（方便用 5j 跳转）

-- 缩进
opt.tabstop = 2             -- Tab 宽度
opt.shiftwidth = 2          -- 缩进宽度
opt.expandtab = true        -- Tab 转空格
opt.autoindent = true
opt.smartindent = true

-- 搜索
opt.hlsearch = false        -- 搜索后不持续高亮
opt.incsearch = true        -- 输入时实时高亮
opt.ignorecase = true       -- 搜索忽略大小写
opt.smartcase = true        -- 含大写时区分大小写

-- 外观
opt.termguicolors = true    -- 24位色彩
opt.signcolumn = "yes"      -- 始终显示 sign 列（避免跳动）
opt.cursorline = true       -- 高亮当前行
opt.scrolloff = 8           -- 光标距屏幕边缘保留 8 行
opt.sidescrolloff = 8
opt.wrap = false            -- 不自动换行

-- 折叠配置
opt.foldmethod = "indent"   -- 用缩进折叠（更稳定）
opt.foldlevel = 99          -- 默认打开所有折叠

-- 系统剪贴板（macOS）
opt.clipboard = "unnamedplus"

-- 分割窗口方向
opt.splitbelow = true
opt.splitright = true

-- 文件
opt.swapfile = false
opt.backup = false
opt.undofile = true         -- 持久化撤销历史
opt.autoread = true         -- 外部修改时自动重载文件

-- 自动检查文件是否被外部修改（Claude/git/其他编辑器）
-- 在光标停留、切 buffer、聚焦窗口、退出输入模式时触发
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.bufexists(0) == 1 then
      vim.cmd("checktime")
    end
  end,
  desc = "自动检查文件是否被外部修改",
})

-- 文件被外部修改时给个提示
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("文件已被外部修改，已自动重载", vim.log.levels.INFO)
  end,
})

-- 补全菜单
opt.completeopt = "menu,menuone,noselect"

-- 更新时间（影响 CursorHold 等事件）
opt.updatetime = 250
opt.timeoutlen = 300        -- 键位超时时间（ms）

-- 鼠标
opt.mouse = "a"
