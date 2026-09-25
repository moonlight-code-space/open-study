# 安装 Open Study 插件

插件包含 Open Study Skill 和远程 MCP 连接配置，不安装第二套本地后端，也不保存上游服务密钥。

## 按正在使用的软件安装

每个 Agent 软件怎么装、去哪里授权、怎么确认能用，都写在手册的连接指引里：https://docs.study.faroapi.cn/connect/overview （给 AI 读的纯文本版：https://docs.study.faroapi.cn/connect/overview.md ）。找到你用的软件那一页照着做；那一页和本文件不一致时，以那一页为准。

最省事的是登录 https://study.faroapi.cn ，打开左侧「快速开始」，选中你的软件，把安装提示词发给它。

需要离线安装时，在「快速开始」页面下方的离线包里选对应文件：Codex、Claude Code、ZCode 用「Codex 插件」（就是这个包）；Claude Code 桌面端用 `.plugin` 文件；大多数其他软件用「标准插件」；Gemini CLI、Antigravity 用各自的兼容包。只连上 MCP 工具、没有装 Skill，不算装完整。

装完先保存手头的工作，按说明页重启软件或新开对话；需要授权时按那一页「授权」一节完成，浏览器里的「允许连接」由用户本人点。然后在新对话里发那一页「确认能用」那句（只查询已有资料，不整理新视频）；查到资料或提示资料库为空，就说明连上了。

正式 MCP 固定连接 `https://study.faroapi.cn/mcp`。稳定更新源是 `moonlight-code-space/open-study` 的 `plugin-stable` 分支。

## 先检查是否已经安装

先查看当前软件的插件清单和安装来源。已经从 GitHub 安装的，按更新说明刷新原来源；不要添加同名本地目录覆盖它。已有 ZIP 来源或其他仓库时，先选择继续按原方式更新还是明确迁移，不自动切换。

GitHub 和网站文件可能暂时不是同一版本。应报告实际安装版本和目标版本的差异，保留更新来源，不为了匹配版本改成本地目录或降级。只有选择离线安装时，才使用下方 ZIP 命令。

## Claude Code、ZCode 和其他软件

步骤见连接指引里对应的那一页，例如 https://docs.study.faroapi.cn/connect/claude-code.md 、https://docs.study.faroapi.cn/connect/zcode.md 。连不上 GitHub、要用这个包离线装 Claude Code 时，把解压出来的 `open-study-codex-marketplace-v版本号` 文件夹当成本地 marketplace 添加（`claude plugin marketplace add <文件夹路径>`），再运行 `claude plugin install open-study@open-study --scope user`；已经从 GitHub 装过的，保留原来的来源。

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
Agent 能打开交互终端时，可协助启动这条登录命令；浏览器里的账户登录和「允许连接」由用户完成。没有交互终端时，再把命令交给用户运行。它会打印一个授权网址并在本机等回调，浏览器里登录 Open Study 并点「允许连接」之后，命令行显示登录成功。插件文件不包含用户 Token、上游服务密钥或云端数据库；不要把这些凭据写进聊天、`.mcp.json` 或 Skill。

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
