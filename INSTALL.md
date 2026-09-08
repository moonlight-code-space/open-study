# 安装 Open Study 插件

插件包含 Open Study Skill 和远程 MCP 连接配置，不安装第二套本地后端，也不保存上游服务密钥。

## 1.1.2：选择安装包

支持 Agent Plugins v1 的软件使用 `open-study-standard-v1.1.2.zip`；Codex 与 Claude Code CLI 使用完整的 `open-study-plugin-v1.1.2.zip`；Claude Code 桌面端按网站指引导入 `open-study-claude-v1.1.2.plugin`。Gemini CLI 与 Antigravity 各有对应兼容包。

不确定怎么选时，下载 `open-study-universal-v1.1.2.zip`，在 `clients/` 找当前软件的说明，或者复制网站「快速开始」中该软件的提示词。合集不是一个能直接被所有软件导入的插件；只安装其中适合自己的那份。标准包和兼容包使用同一份 Skill、同一个远程服务。后续版本以[网站快速开始](https://study.faroapi.cn/#ai)和[正式发布页](https://github.com/moonlight-code-space/open-study/releases/latest)为准。

只有 MCP 工具连接，没有加载 Skill，不能视为完整安装。客户端版本不支持时，应明确说明缺哪一项。

安装完成后，先保存手头的工作，完全退出并重新打开安装插件的那个软件，再新开一个对话。如果用的是命令行，就退出当前会话后重新启动。需要登录时按提示授权；新对话里实际调用成功后，才算确认能用。

正式 MCP 固定连接 `https://study.faroapi.cn/mcp`。插件安装成功只说明 Skill
和连接声明已经进入客户端；账号授权是单独一步，按下方客户端说明完成。稳定更新源是
`moonlight-code-space/open-study` 的 `plugin-stable` 分支。

## 从 ZIP 安装（当前推荐）

从网站「快速开始」下载的 ZIP 安装即用，安装不依赖 GitHub；使用仍需联网到远程 MCP 与授权。解压完整安装包，然后运行下方 ZIP 安装命令。想跟着仓库自动更新，用后面的 GitHub 方式。

## Claude Code

插件包同时带有 Claude Code 的清单（`plugins/open-study/.claude-plugin/plugin.json`，仓库根另有 `.claude-plugin/marketplace.json`），可以当作一个 Claude Code marketplace 直接安装。

账号级安装（对本机所有项目生效）：

```bash
claude plugin marketplace add https://github.com/moonlight-code-space/open-study.git
claude plugin install open-study@open-study --scope user
```

`claude plugin marketplace add` 不支持指定分支，Claude 走的是仓库默认分支 `main`；`main` 与 `plugin-stable` 两个分支的插件内容相同。

在 Claude Code 会话里也可以用 `/plugin marketplace add …` 与 `/plugin install open-study@open-study`，后者会弹出作用域选择，选「User」。装完之后要单独登录一次：安装时不问授权，第一次调用也不弹窗，服务会显示 `! Needs authentication`。在能打字的终端里跑 `claude mcp login "plugin:open-study:open-study"`（服务名的 `plugin:` 前缀和引号都不能省），或在会话里用 `/mcp` 选 open-study 登录；非交互环境会报 `stdin isn't a terminal`。浏览器会打开网站的授权页，登录后点「允许连接」；密码不经过插件。

更新：先 `claude plugin marketplace update open-study`，再 `claude plugin update open-study@open-study`。换到只对当前项目生效，用 `--scope project`（写进仓库的 `.claude/settings.json`，会随代码共享）或 `--scope local`（只在本机这个目录）。

## Claude Code 桌面端

在网站「快速开始」选择 **Claude Code 桌面端**，下载对应的 `.plugin` 包，按页面步骤导入，并完成 Open Study 账号授权。更新时重新下载并导入新版本；不要把普通 Claude 连接器页面当成插件导入入口。

## 其他 Agent（Cursor、Cline 等）

包里的安装脚本面向 Codex。其他客户端应按网站「快速开始」和对应包内说明，加载完整 Skill 及其附属文件，再连接远程 MCP `https://study.faroapi.cn/mcp` 并完成账号授权。客户端只接通 MCP、尚未加载 Skill 时，应明确说明“工具已连接，Skill 未加载”，不能称为完整安装。不要把永久粘贴系统提示词当成已验证的插件安装方式；没有对应说明的客户端先确认其实际支持能力。

## Codex：从 GitHub 安装

在已安装 Codex CLI 的 macOS、Linux 或 Windows 终端运行：

```text
codex plugin marketplace add moonlight-code-space/open-study --ref plugin-stable --json
codex plugin add open-study@open-study --json
```

如果已有同名本地 ZIP 来源、其他仓库或来源冲突，先保留当前配置，按 [更新说明](UPDATE.md) 核对；不要删除来源来绕过报错。下载包中的 `install.sh` 和 `install.ps1` 也可用于安装，公共 Git 仓库本身不包含这些脚本。

安装成功后，新建一个 Codex 任务，再让 Agent 使用 Open Study。若尚未授权或新对话提示登录，再在能打字的终端里运行 `codex mcp login open-study`；已有授权且能读取资料时无需重复登录。
它会打印一个授权网址并在本机等回调，浏览器里登录 Open Study 并点「允许连接」之后，命令行显示登录成功。插件文件不包含用户 Token、TikOmni 密钥或云端数据库；不要把这些凭据写进聊天、`.mcp.json` 或 Skill。

下载包安装器会先检查同名 marketplace。如果已有另一个 GitHub 来源、不是 `plugin-stable` 的 Git ref 或旧 ZIP 本地来源，它会停止并保留原配置。若安装器刚添加了一个新 marketplace、但随后的插件安装失败，它会只回滚本次新增的 marketplace；既有 marketplace 和既有插件不会被自动删除。

## ZIP 安装命令

解压完整安装包，然后运行：

### macOS / Linux

```sh
sh ./install.sh --offline
```

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Offline
```

ZIP 是本地 marketplace，安装期间和安装后都要保留解压目录。它不会自动从 GitHub 更新；恢复联网并且正式仓库已发布后，再按更新说明明确迁移到 Git marketplace。

## 更新

已从 GitHub 安装时，按 [UPDATE.md](UPDATE.md) 核对原来源，再刷新 marketplace 并安装新版本。该页也说明旧更新器无法读取 Git ref 元数据时的处理方式。离线包更新与 GitHub 更新分开处理。

## 插件里有什么

- `SKILL.md`：帮助 Agent 在设计、规划、学习操作和其他实践任务中考虑教程、案例及已有资料。已要求研究或授权主动参考时，直接查找、读取并用于原任务；还没授权时，可先说明参考的用途。实际触发取决于客户端、模型和对话，不保证每次都会主动建议。
- 对用户要求读取或整理的受支持公开链接，Agent 按请求范围处理，等资料返回后再回答；链接只是示例或用户明确不需要研究时不提交。新链接由 Agent 自己的联网搜索发现，Open Study 负责读取和整理，普通网页由浏览器或网页工具读取。
- `.mcp.json`：只声明 `https://study.faroapi.cn/mcp`。登录、账号隔离、计费和任务执行都由远程服务处理。
- marketplace 元数据：让 Codex 从 GitHub 稳定分支安装或刷新插件。

Agent 会区分资料原话和自己的建议，保留可核对的来源。已经授权的范围不逐条重复询问；新增费用、扩大范围或需要账号授权时，仍按当前请求和客户端权限处理。正常使用不需要反复查询连接状态，出现连接错误时再排查。

## 从旧版 `bilistudy` Skill / MCP 迁移

Open Study 使用新的 Skill 名 `open-study` 和 MCP 名 `open-study`，安装器不会删除或改写旧的 `bilistudy` 配置。安全迁移顺序是：

1. 保留旧配置，先安装 Open Study；新建 Codex 任务，明确使用 `$open-study`。
2. 完成网站 OAuth，并用 `system_status` 和一次资料库搜索确认新连接属于正确账号。需要验证写入时，明确要求 `$open-study` 处理一个公开 B 站链接；这条请求本身就是该链接的一次采集授权。
3. 只有确认新连接可用后，才在 Codex 设置中停用旧 `bilistudy` MCP 和旧 Skill。修改前备份配置，并且只处理同名旧项；不要覆盖其他 MCP、Skill 或个人设置。
4. 旧本地资料库不会因安装插件自动上传到云端。继续保留旧应用和数据，除非以后有经过验证的导入流程；不要把本地数据库、Token 或上游密钥塞进插件目录。

如果新旧两套暂时并存，请显式说“使用 `$open-study`”，避免 Agent 误选旧的本地工作流。
