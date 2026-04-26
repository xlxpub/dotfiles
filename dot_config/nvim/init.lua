-- 屏蔽三方插件的 deprecated 告警（lspsaga/illuminate/trouble 等暂未完全跟上 nvim 0.12 API）
-- 若需排查 deprecation 问题，注释此行即可恢复告警
vim.deprecate = function() end

-- 加载顺序：选项 → 键位 → 插件管理器 → 插件
require("options")
require("keymaps")
require("lazy-bootstrap")
vim.opt.clipboard = 'unnamedplus' -- 核心：默认y同步到系统剪切板
