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
opt.timeoutlen = 500        -- 键位超时时间（ms），三键组合如 <leader>yf 需要足够时间

-- 鼠标
opt.mouse = "a"

-- ══════════════════════════════
--  终端窗口标题（iTerm2 标签显示当前目录/文件）
-- ══════════════════════════════
opt.title = true
-- 始终显示 CWD 最后一级目录名
opt.titlestring = [[%{fnamemodify(getcwd(),":t")}]]
-- nvim 退出时恢复为上一级标题（iTerm2 恢复 zsh 的目录标题）
opt.titleold = ""

-- ══════════════════════════════
--  Go 工具链环境变量注入
--  修复 gopls 启动时报 "identify GOROOT dir cmd failed"
--  原因：nvim 从 GUI / 其他启动器启动时未继承 shell 的 Go 环境
-- ══════════════════════════════
if vim.fn.executable("go") == 1 then
  if not vim.env.GOROOT or vim.env.GOROOT == "" then
    local goroot = vim.fn.trim(vim.fn.system("go env GOROOT"))
    if vim.v.shell_error == 0 and goroot ~= "" then
      vim.env.GOROOT = goroot
    end
  end
  if not vim.env.GOPATH or vim.env.GOPATH == "" then
    local gopath = vim.fn.trim(vim.fn.system("go env GOPATH"))
    if vim.v.shell_error == 0 and gopath ~= "" then
      vim.env.GOPATH = gopath
    end
  end
  -- 确保 $GOROOT/bin 和 $GOPATH/bin 在 PATH 里（gopls 需要能找到 go 命令）
  if vim.env.GOROOT and not vim.env.PATH:find(vim.env.GOROOT .. "/bin", 1, true) then
    vim.env.PATH = vim.env.GOROOT .. "/bin:" .. vim.env.PATH
  end
  if vim.env.GOPATH and not vim.env.PATH:find(vim.env.GOPATH .. "/bin", 1, true) then
    vim.env.PATH = vim.env.GOPATH .. "/bin:" .. vim.env.PATH
  end
end
