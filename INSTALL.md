# 安装 Open Study 插件

插件包含 Open Study Skill 和远程 MCP 连接配置，不安装第二套本地后端，也不保存上游服务密钥。

## 按正在使用的软件安装

在网站「连接 AI」选择正在使用的软件，复制对应安装提示词。Codex CLI、Codex 桌面端与 Claude Code CLI 优先使用官方 GitHub 更新源，日后仍从同一来源更新。下载文件是备用方式，不需要把所有包都装上。

需要离线安装时，在网站选择当前版本的文件：支持 Agent Plugins v1 的软件用标准包；Codex 与 Claude Code CLI 用完整发行包；Claude Code 桌面端用 `.plugin` 文件。Gemini CLI 与 Antigravity 使用各自兼容包。

「全部安装材料」是合集，在 `clients/` 找当前软件的说明，只安装对应的那份；合集不能作为一个插件整体导入。标准包和兼容包使用同一份 Skill、同一个远程服务。文件名中的版本以网站实际下载为准。

只有 MCP 工具连接，没有加载 Skill，不能视为完整安装。客户端版本不支持时，应明确说明缺哪一项。

安装完成后，先保存手头的工作，完全退出并重新打开安装插件的那个软件，再新开一个对话。如果用的是命令行，就退出当前会话后重新启动。需要登录时按提示授权；新对话里实际调用成功后，才算确认能用。

正式 MCP 固定连接 `https://study.faroapi.cn/mcp`。插件安装成功只说明 Skill
和连接声明已经进入 Codex；安装期间或首次使用时仍要通过网站 OAuth 登录。稳定更新源是
`moonlight-code-space/open-study` 的 `plugin-stable` 分支。

## 先检查是否已经安装

先查看当前软件的插件清单和安装来源。已经从 GitHub 安装的，按更新说明刷新原来源；不要添加同名本地目录覆盖它。已有 ZIP 来源或其他仓库时，先选择继续按原方式更新还是明确迁移，不自动切换。

GitHub 和网站文件可能暂时不是同一版本。应报告实际安装版本和目标版本的差异，保留更新来源，不为了匹配版本改成本地目录或降级。只有选择离线安装时，才使用下方 ZIP 命令。

## Claude Code

插件包同时带有 Claude Code 的清单（`plugins/open-study/.claude-plugin/plugin.json`，仓库根另有 `.claude-plugin/marketplace.json`），可以当作一个 Claude Code marketplace 直接安装。

首次账号级安装（对本机所有项目生效；已经安装的先查看来源并走更新）：

```bash
claude plugin marketplace add https://github.com/moonlight-code-space/open-study.git
claude plugin install open-study@open-study --scope user
```

`claude plugin marketplace add` 不支持指定分支，Claude 走的是仓库默认分支 `main`；`main` 与 `plugin-stable` 两个分支的插件内容相同。

在 Claude Code 会话里也可以用 `/plugin marketplace add …` 与 `/plugin install open-study@open-study`，后者会弹出作用域选择，选「User」。安装后若显示 `Needs authentication`，或调用时提示未登录，可在会话里用 `/mcp` 选 open-study 登录，也可在交互终端运行 `claude mcp login "plugin:open-study:open-study"`（按实际插件服务名填写）。Agent 能打开交互终端时可协助启动；浏览器里的账户登录和「允许连接」由用户完成。没有交互终端时，再把命令交给用户运行。浏览器会打开网站的授权页，登录后点「允许连接」；密码不经过插件。

更新：先 `claude plugin marketplace update open-study`，再 `claude plugin update open-study@open-study`。换到只对当前项目生效，用 `--scope project`（写进仓库的 `.claude/settings.json`，会随代码共享）或 `--scope local`（只在本机这个目录）。

## Claude Code 桌面端

下载当前版本的 `open-study-claude-*.plugin`，在 Claude Code 桌面端的插件页导入。不要上传 Codex 的 marketplace ZIP，也不要把普通 Claude 聊天连接器当成桌面插件。升级后重开软件、新建对话，再确认插件版本与授权；尚未实际调用时，只能说文件已安装。

## 其他 Agent（Cursor、Cline 等）

包里的安装脚本面向 Codex。其他软件先按 `clients/` 对应说明确认当前版本支持的插件、Skill 与 MCP 安装方式；保留完整 Skill 目录及其附属文件。只有工具连接而没有 Skill 的软件，应说明缺项，不把整篇 Skill 强行塞进每条对话。远程服务使用 `https://study.faroapi.cn/mcp`，需要登录时按当前软件的授权流程完成。

## Codex：从 GitHub 安装（推荐）

安装器拒绝其他 Git ref、同名 ZIP 来源和不同 GitHub 仓库，不会静默改写
来源。在源码仓库根目录使用 `scripts/` 下的安装器；如果手边只有已解压的
离线包，也可以使用包根目录的安装器连接 GitHub。

### macOS / Linux

```sh
sh ./scripts/Install-OpenStudy-Plugin.sh moonlight-code-space/open-study
```

也可以传完整地址：

```sh
sh ./scripts/Install-OpenStudy-Plugin.sh https://github.com/moonlight-code-space/open-study
```

在解压包根目录运行：

```sh
sh ./install.sh moonlight-code-space/open-study
```

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-OpenStudy-Plugin.ps1 moonlight-code-space/open-study
```

在解压包根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 moonlight-code-space/open-study
```

安装成功后，新建一个 Codex 任务，再让 Agent 使用 Open Study。需要授权时，Codex 会进入正常的连接和登录流程。

Codex 安装后若提示未登录或尚未完成授权，可在交互终端运行 `codex mcp login open-study`。不同版本是否自动弹出授权可能不同，以实际提示为准。
Agent 能打开交互终端时，可协助启动这条登录命令；浏览器里的账户登录和「允许连接」由用户完成。没有交互终端时，再把命令交给用户运行。它会打印一个授权网址并在本机等回调，浏览器里登录 Open Study 并点「允许连接」之后，命令行显示登录成功。插件文件不包含用户 Token、TikOmni 密钥或云端数据库；不要把这些凭据写进聊天、`.mcp.json` 或 Skill。

安装器会先检查同名 marketplace。如果已有另一个 GitHub 来源、不是 `plugin-stable` 的 Git ref 或旧 ZIP 本地来源，它会停止并保留原配置，不会静默覆盖。若安装器刚添加了一个新 marketplace、但随后的插件安装失败，它会只回滚本次新增的 marketplace；既有 marketplace 和既有插件不会被自动删除。

## ZIP 安装命令（离线备用）

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

## 等价的 Codex 命令

GitHub 安装器使用以下命令，并额外检查来源冲突和失败状态：

```text
codex plugin marketplace add moonlight-code-space/open-study --ref plugin-stable --json
codex plugin add open-study@open-study --json
```

完成一次 GitHub 安装后，日常更新不必再输入仓库地址：运行 `Update-OpenStudy-Plugin` 脚本即可。离线包内也包含 `UPDATE.md`。

## 插件里有什么

- `SKILL.md`：指导 Agent 在学习操作、创作设计、制定方案、比较方法等任务中识别有用的教程和案例，按已有研究需求读取资料，并把结果用回原任务。无需查资料的小改动直接完成。安装了 Skill 不代表每次都能稳定主动提醒，实际表现需用新对话验证。
- `.mcp.json`：只声明 `https://study.faroapi.cn/mcp`。登录、账号隔离、计费和任务执行都由远程服务处理。
- marketplace 元数据：让 Codex 从 GitHub 稳定分支安装或刷新插件。

旧版本地 Skill 的证据回链和来源区分逻辑已经复用；云端版本把采集前检查收进后台流程，并取消采集前的额外确认轮次。本机后端发现、CLI 和本地数据库部分不会带入云端插件。

## 从旧版 `bilistudy` Skill / MCP 迁移

Open Study 使用新的 Skill 名 `open-study` 和 MCP 名 `open-study`，安装器不会删除或改写旧的 `bilistudy` 配置。安全迁移顺序是：

1. 保留旧配置，先安装 Open Study；新建 Codex 任务，明确使用 `$open-study`。
2. 完成网站 OAuth，并用 `system_status` 和一次资料库搜索确认新连接属于正确账号。需要验证写入时，明确要求 `$open-study` 处理一个公开 B 站链接；这条请求本身就是该链接的一次采集授权。
3. 只有确认新连接可用后，才在 Codex 设置中停用旧 `bilistudy` MCP 和旧 Skill。修改前备份配置，并且只处理同名旧项；不要覆盖其他 MCP、Skill 或个人设置。
4. 旧本地资料库不会因安装插件自动上传到云端。继续保留旧应用和数据，除非以后有经过验证的导入流程；不要把本地数据库、Token 或上游密钥塞进插件目录。

如果新旧两套暂时并存，请显式说“使用 `$open-study`”，避免 Agent 误选旧的本地工作流。
