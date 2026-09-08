# 更新 Open Study Codex 插件

Open Study 的 Skill 和 MCP 连接配置跟随 GitHub 的 `plugin-stable` 分支更新。远程 MCP 服务由服务端更新，不会把后端或上游密钥下载到本机。

稳定更新源是 `moonlight-code-space/open-study` 的
`plugin-stable` 分支。更新完成后，先保存手头的工作，完全退出并重新打开安装插件的那个软件，再新开一个对话；命令行用户退出当前会话后重新启动。随后实际调用一次确认能用，不要把文件更新成功当作已经加载成功。

## Codex：核对来源后更新

以下命令适用于已从官方 GitHub 仓库安装、并且你准备更新的 Codex 插件；macOS、Linux 和 Windows 使用相同命令。

先查看已配置的来源：

```text
codex plugin marketplace list --json
```

只检查名称为 `open-study` 的条目：它应当只有一项，来源类型是 Git，仓库是 `moonlight-code-space/open-study` 或等价的官方 HTTPS 地址。若结果提供 `refName`、`ref` 或 `gitRef`，应为 `plugin-stable`。来源是本地 ZIP、其他仓库、其他 ref、重复条目或无法核实时，保留配置，先处理来源问题。

核对后依次运行；第一条失败时先处理错误，不继续安装：

```text
codex plugin marketplace upgrade open-study --json
codex plugin add open-study@open-study --json
```

这会刷新已配置的 Git marketplace，再安装其中的插件，不重新添加或删除来源，也不更改工具审批和账号授权设置。查看安装结果里的插件 ID 与版本；本轮版本为 `1.1.2`，后续以正式发布页为准。更新后按开头说明重新加载客户端，实际查询一次已有资料即可，不必反复检查状态。

### 更新脚本提示无法确认 Git ref

下载包里的 `update.sh`／`update.ps1` 另做了来源校验。部分 Codex CLI 的 marketplace 结果只提供 Git 仓库来源，没有 ref 字段，旧更新器会因此拒绝继续。这种报错本身不表示插件损坏或安装失败。

如果确实只是缺少 ref 元数据，先按上面的步骤确认唯一的官方 Git 来源，再使用上述 `marketplace upgrade` 和 `plugin add` 命令更新原来源。若明确显示另一个 ref 或无法确认来源，则不能套用这个办法。不要伪造 ref 字段、删除 marketplace，或改审批设置来让脚本通过。

更新插件不等于重新授权账号。出现登录要求时，按客户端正常的 Open Study 登录流程完成；已经连上的账号不需要为了更新而重复登录。若刷新成功但安装失败，记录具体错误后处理，不把 marketplace 刷新成功当作插件已更新。

## Claude 与下载包

Claude Code 的官方 GitHub 安装先运行 `claude plugin marketplace update open-study`，再运行 `claude plugin update open-study@open-study`。Claude Code 桌面端按网站「快速开始」重新下载并导入对应包；普通 Claude 连接器页面不等于插件导入入口。

从本地 ZIP 安装的 Codex 插件应保留原解压目录，按下载包说明更新；不要把它当成 Git marketplace 执行上面的命令。公共 Git 仓库不包含 `scripts/Update-OpenStudy-Plugin.sh`；包内脚本仅在完整解压目录使用。

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
