-- 终端与 Claude Code 互斥切换工具
-- 打开其中一个时自动隐藏另一个

local M = {}

--- 隐藏所有可见的 Snacks 终端窗口
function M.hide_snacks_terminal()
  local ok, _ = pcall(function()
    local terminals = Snacks.terminal.list()
    for _, term in ipairs(terminals) do
      -- 检查终端是否有可见窗口
      if term.win and vim.api.nvim_win_is_valid(term.win) then
        term:hide()
      end
    end
  end)
  if not ok then
    -- Snacks 未加载或没有打开的终端，忽略
  end
end

--- 隐藏 Claude Code 窗口（如果可见）
function M.hide_claude()
  local ok, claude = pcall(require, "claude-code")
  if not ok or not claude.claude_code then return end

  local instances = claude.claude_code.instances
  if not instances then return end

  for _, bufnr in pairs(instances) do
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      local win_ids = vim.fn.win_findbuf(bufnr)
      for _, win_id in ipairs(win_ids) do
        vim.api.nvim_win_close(win_id, true)
      end
    end
  end
end

return M
