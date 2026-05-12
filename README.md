# Dotfiles (chezmoi)

chezmoi 管理的 dotfiles 仓库，支持 Intel x86_64 和 Apple Silicon arm64 两台 Mac。

## 架构

```
.
├── dot_zshrc.tmpl          # zsh 配置（模板）
├── dot_env.tmpl            # 环境变量（模板，敏感值从 chezmoi.toml 读取）
├── dot_golangci.yaml       # golangci-lint 配置
├── dot_config/             # ~/.config/ 下的配置
│   └── nvim/               # Neovim 配置
├── private_dot_ssh/        # SSH 配置
└── docs/                   # 文档
```

## 敏感文件管理

`~/.env` 通过模板方式管理，敏感值存储在 `~/.config/chezmoi/chezmoi.toml` 的 `[data]` 段中。

- `chezmoi.toml` 不提交 git，每台机器手动维护
- `dot_env.tmpl` 引用模板变量渲染生成 `~/.env`
- 新机器部署时只需手动创建 `chezmoi.toml` 填入密钥

## 变更记录

- 2026-05-09: 将 `~/.env` 改为 chezmoi 模板管理，敏感值存入 `chezmoi.toml`
- 2026-05-12: 添加 Ghostty 终端配置，启用下拉式快速终端（`Cmd + `` 触发）
