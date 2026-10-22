# Lazygit 集成（分屏 / 浮窗）

## 启动方式

不再使用 `lazygit.nvim`，改为 `lua/tools/lazygit.lua` 自己实现，两种窗口形态共用同一套退出清理逻辑。

| 键位 | 功能 |
| --- | --- |
| `<leader>gg` | 下方普通分屏打开 Lazygit（高度约 35%） |
| `<leader>gF` | 浮窗打开 Lazygit（默认 90% 屏幕，圆角边框） |
| `<leader>gG` | 分屏 + 只看当前文件（`-f`） |
| `<leader>gl` | 分屏 + 提交日志（`lazygit log`） |

浮窗尺寸可调：`vim.g.lazygit_floating_window_scaling_factor`（默认 0.9）、
`vim.g.lazygit_floating_window_winblend`、`vim.g.lazygit_floating_window_border_chars`，
都在 `M.float()` 打开时实时读取。

## 在 lazygit 里按 e 打开文件

依赖 neovim-remote（`nvr`，装在 `~/.local/bin/nvr`）。

`~/Library/Application Support/lazygit/config.yml`：

```yaml
os:
  edit: '$HOME/.local/bin/nvr -cc "tabnew" --remote-wait +''set bufhidden=wipe'' "{{filename}}"'
  editAtLine: '$HOME/.local/bin/nvr -cc "tabnew" --remote-wait +''set bufhidden=wipe'' +{{line}} "{{filename}}"'
```

要点：

- `tabnew`：在新 tab 全屏打开文件；`:q` 关闭后回到原 tab，lazygit 和布局原样恢复
- 与窗口形态无关：分屏或浮窗下 `e` 都是开新 tab（浮窗实测 tab 2/2 打开文件，浮窗留在 tab 1）
- `--remote-wait`：lazygit 阻塞，直到该 buffer 被卸载
- `+'set bufhidden=wipe'` 必需：否则 `:q` 只隐藏 buffer，nvr 永不返回，lazygit 卡死
- 用 `$HOME` 展开绝对路径：lazygit 走 `sh -c`，不读 zshrc，裸 `nvr` 可能找不到

### 为什么不用 split 打开文件

lazygit 自己占了底部 35%，配合 `splitbelow=true`，`:split` 出来的窗口会被夹在
主窗口和 lazygit 之间（实测 13/14/13 三段），所以改用 `tabnew`。

## 验证

1. `<leader>gg` / `<leader>gF` → 分屏或浮窗出现，lazygit 可用
2. 选中文件按 `e` → 新 tab 全屏打开，lazygit 暂停等待
3. `:q` → 回到原 tab；浮窗模式下按 `q` 退出 lazygit 后浮窗自动关闭

## 已知问题

`nvr --version` 报 `No module named 'pkg_resources'`：setuptools 84 移除了该模块，nvr 2.5.1 仍引用。不影响功能。
修复：`python3 -m pip install --user 'setuptools<81'`。


## 返回时不再按回车

lazygit 从外部编辑器返回后默认会显示 "Press enter to return to lazygit"，关闭：

```yaml
gui:
  promptToReturnFromSubprocess: false
```

这样 `:q` 关掉文件 tab 后直接回到 lazygit 界面，不用再按一次回车。

