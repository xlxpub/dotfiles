-- Lazygit：分屏（split）或浮窗（float）启动
-- 配合 nvr：在 lazygit 里按 e 会在新 tab 打开文件，与窗口形态无关
local M = {}

local win = nil

local function build_cmd(args)
  local cmd = "lazygit"
  if args and #args > 0 then
    cmd = cmd .. " " .. table.concat(args, " ")
  end
  return cmd
end

local function track_exit(buf)
  local w = win
  win = nil
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if w and vim.api.nvim_win_is_valid(w) then
          vim.api.nvim_win_close(w, true)
        end
        vim.cmd("silent! checktime")
      end)
    end,
  })
end

--- 下方普通分屏启动；args 为附加参数，如 { "log" } 或 { "-f", "file" }
function M.split(args)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
    return
  end

  local height = math.max(10, math.floor(vim.o.lines * 0.75))
  vim.cmd(("botright %dsplit"):format(height))
  win = vim.api.nvim_get_current_win()

  vim.cmd("terminal " .. build_cmd(args))
  vim.cmd("startinsert")
  track_exit(vim.api.nvim_get_current_buf())
end

--- 浮窗启动；尺寸/透明度读 vim.g.lazygit_floating_window_*
function M.float(args)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
    return
  end

  local scale = tonumber(vim.g.lazygit_floating_window_scaling_factor) or 0.9
  local width = math.floor(vim.o.columns * scale)
  local height = math.floor(vim.o.lines * scale) - 1
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = vim.g.lazygit_floating_window_border_chars or "rounded",
  })

  local blend = tonumber(vim.g.lazygit_floating_window_winblend)
  if blend then
    vim.wo[win].winblend = blend
  end

  vim.cmd("terminal " .. build_cmd(args))
  vim.cmd("startinsert")
  track_exit(vim.api.nvim_get_current_buf())
end

--- 默认走分屏（兼容旧调用）
function M.open(args)
  M.split(args)
end

return M

