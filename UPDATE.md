# 更新 Open Study Codex 插件

Open Study 的 Skill 和 MCP 连接配置跟随 GitHub 的 `plugin-stable` 分支更新。远程 MCP 服务由服务端更新，不会把后端或上游密钥下载到本机。

稳定更新源是 `moonlight-code-space/open-study` 的
`plugin-stable` 分支。更新完成后，先保存手头的工作，完全退出并重新打开安装插件的那个软件，再新开一个对话；命令行用户退出当前会话后重新启动。随后实际调用一次确认能用，不要把文件更新成功当作已经加载成功。

## macOS / Linux

已经从 GitHub 安装后，在源码仓库根目录运行：

```sh
sh ./scripts/Update-OpenStudy-Plugin.sh
```

可选地传入已发布仓库做额外来源核对：

```sh
sh ./scripts/Update-OpenStudy-Plugin.sh https://github.com/moonlight-code-space/open-study
```

如果你打开的是下载包内的 `UPDATE.md`，脚本就在同一目录：

```sh
sh ./update.sh
```

## Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Update-OpenStudy-Plugin.ps1
```

如果你打开的是下载包内的 `UPDATE.md`：

```powershell
powershell -ExecutionPolicy Bypass -File .\update.ps1
```

脚本只执行两步：先刷新已配置的 Git marketplace，再从该快照重新安装 `open-study`。它会从 Codex 已保存的 marketplace 读取仓库来源，并要求该来源仍固定在 `plugin-stable`；如果检测到同名 ZIP marketplace、另一个 GitHub 仓库、其他 Git ref 或重复 marketplace，会停止，不会替换或删除原配置。

这个流程只更新轻量的 Skill 与 MCP 连接元数据，不下载云端后端，也不重启数据库。网络正常时通常只需数秒；实际时间取决于 GitHub 和 Codex marketplace 刷新速度。远程 MCP 功能由 Open Study 服务端单独发布，客户端不需要为服务端更新重装插件。

刷新失败时，原来已安装的插件和 marketplace 都不变。若刷新成功但重新安装失败，原来已安装的插件仍保留，但本地 marketplace 快照可能已经前移；修复错误后重跑更新。成功后请新建一个 Codex 任务，让新的 Skill 和 MCP 工具进入任务上下文。

## 从 ZIP 安装迁移到 GitHub

自动更新不会替换旧的本地 marketplace。先确认旧插件仍可用、记下旧解压目录的绝对路径，并确认正式 GitHub 仓库已经发布。以下 `marketplace remove` 会同时卸载当前插件，不是无影响的探测命令：

```text
codex plugin marketplace remove open-study
```

随后立即按安装说明从 GitHub 安装。在原解压包根目录可直接运行：

```sh
sh ./install.sh moonlight-code-space/open-study
```

Windows 使用：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 moonlight-code-space/open-study
```

如果 GitHub 安装失败，用保留的旧解压目录恢复离线来源：

```text
codex plugin marketplace add /旧解压目录的绝对路径 --json
codex plugin add open-study@open-study --json
```

确认 marketplace 已切换到 GitHub、新任务能加载 Skill 与 MCP 后，才可以删除旧解压目录。

## 维护者发布流程

1. 在普通开发分支完成插件、Skill 和 MCP 配置修改。
2. 验证 `.agents/plugins/marketplace.json` 与 `plugins/open-study/`，并完成隔离安装测试。
3. 只在测试通过后，把确认过的提交更新到远端 `plugin-stable`。
4. 保留对应 Git tag 或 GitHub Release，便于审计和回退。用户更新失败时不要让用户猜 commit；维护者先把 `plugin-stable` 恢复到最近一次验证通过的提交，再让用户重跑更新。
5. 通知用户运行更新脚本并新建 Codex 任务。

GitHub 仓库必须保留仓库根目录的 `.agents/plugins/marketplace.json`、`plugins/open-study/` 和 `plugin-stable` 分支。开发分支未通过门禁前不要推进稳定分支；需要回退时，把 `plugin-stable` 恢复到已验证提交并再次刷新 marketplace。

提交稳定分支前运行仓库内的权威离线门禁：

```bash
.venv/bin/python scripts/Test-OpenStudy-Plugin-Update.py
.venv/bin/python scripts/validate-open-study-plugin.py --marketplace-root .
```

校验脚本依赖 PyYAML，请用仓库 `.venv` 里的解释器运行。

`plugin-stable` 是客户端的稳定更新通道，不应直接作为日常开发分支。正式
来源固定为 `moonlight-code-space/open-study`；变更仓库或 ref
必须作为新的发布决策重新验收，客户端安装器不会静默跟随。
