改动总结

  1. nvim 插件（~/.config/nvim/lua/plugins/git.lua）

  新增 kdheepak/lazygit.nvim：

  ┌────────────┬──────────────────────┐
  │    键位    │         功能         │
  ├────────────┼──────────────────────┤
  │ <leader>gg │ 打开 Lazygit（浮窗） │
  ├────────────┼──────────────────────┤
  │ <leader>gG │ Lazygit 打开当前文件 │
  ├────────────┼──────────────────────┤
  │ <leader>gl │ Lazygit 查看提交日志 │
  └────────────┴──────────────────────┘

  关键配置 vim.g.lazygit_use_neovim_remote = 1 —— 让 lazygit 里 o/e 打开文件时回到当前 nvim 实例并跳到对应行，而不是新起进程。

  2. lazygit 配置（~/Library/Application Support/lazygit/config.yml）

  原本是空文件，现写入：
  - os.editPreset: "nvim" —— 编辑器预设
  - nerdFontsVersion: "3"、文件树视图等 GUI 设置
  - git.autoFetch/autoRefresh: true —— 自动刷新

  │ 注意：你的主题是通过 lgs 别名 --use-config-file 单独加载的（frappe/sky.yml），不会被这个 config.yml 覆盖，两者独立工作。

  3. chezmoi 同步

  - .config/nvim/lua/plugins/git.lua
  - Library/Application Support/lazygit/config.yml

  生效方式

  重开 nvim 或者：
  :Lazy sync

  然后按空格 gg 即可唤起 lazygit。

  验证要点

  - 在 lazygit 里选中文件按 o，应回到 nvim 打开该文件（而非弹新终端）
  - 若回跳失败，检查 nvim 是否带 --listen（lazygit_use_neovim_remote 需要 nvim server，通常 lazy.nvim 环境已支持）

  需要我顺便把 lazygit 的常用自定义键位（比如和 nvim leader 对齐）也配进去吗？
