---
name: skills-manager
description: 检查、安装和更新 bb-game Agent Skills。用户要求更新/检查/安装 skills 或提到 skills 版本旧时使用；执行由跨 Agent 的 skills-manager CLI 完成。
version: 2026.09.07.1
source: https://github.com/bb-game/skills
---

# Skills Manager

这个 Skill 是跨 Agent 的薄入口。真正的更新逻辑必须交给 `skills-manager` CLI，不要手工覆盖 `~/.codex/skills`、`~/.claude/skills` 或 `~/.agents/skills`。

## 自动触发

- 用户说“更新 skills / 更新 knowledge-memory / 检查 skills 版本”。
- 用户要求安装 bb-game 的某个 Skill。
- 用户反馈 Skill 行为像旧版本，且远端仓库已发布新版本。

## 命令

查看本地状态：

```bash
skills-manager status
```

检查远端是否有更新：

```bash
skills-manager check
```

更新 Codex 和 Claude Code：

```bash
skills-manager update
```

只更新一个 Skill：

```bash
skills-manager update --skill knowledge-memory
```

同步到共享目录：

```bash
skills-manager update --agents codex,claude,shared
```

首次安装：

```bash
tmp=$(mktemp -d)
git clone --depth 1 https://github.com/bb-game/skills.git "$tmp/skills"
"$tmp/skills/skills-manager/bin/skills-manager" update
rm -rf "$tmp"
```

首次安装后，如果 `~/.local/bin` 不在 PATH 中，把下面一行加入 shell 配置：

```bash
export PATH="$HOME/.local/share/skills-manager/bin:$PATH"
```

Windows PowerShell 首次安装：

```powershell
$tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ([Guid]::NewGuid().ToString()))
git clone --depth 1 https://github.com/bb-game/skills.git "$($tmp.FullName)\skills"
& "$($tmp.FullName)\skills\skills-manager\bin\skills-manager.cmd" update --agents codex,claude
$env:Path = "$env:LOCALAPPDATA\skills-manager\bin;$env:Path"
```

Windows 数据目录默认是 `%LOCALAPPDATA%\skills-manager`，可执行入口是 `skills-manager.cmd`。

## 安全规则

- 只更新 `skills.json` 声明的 Skills。
- 不修改 `.system`、内置插件 Skills 或其他未管理目录。
- 更新前默认备份旧目录到 `~/.local/share/skills-manager/backups`。
- 不执行仓库中的任意 shell 钩子。
- 不更新用户明确没有提到的无关 Skill，除非用户要求更新所有 Skills。
- 如果 CLI 报错，把错误原样告诉用户；不要手工删除目标目录来绕过错误。
