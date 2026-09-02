# Open Study

让 AI 学会你正在学习的事。

粘贴一条视频链接，你的 Agent 就能读到视频里讲了什么、评论区怎么说，然后带着出处回答你，或者照着做。

# Open Study 能干什么？

### 你贴一条链接，它整理成资料
**你说：** "整理这个视频，告诉我怎么完成里面的操作。"
Agent 把字幕、评论、封面收进你的资料库，附一份分析和一张总结图，然后按视频里的步骤给你一份操作清单。没有字幕的视频，它听音频转成文字。

### 你记得半句话，它翻出那条视频
**你说：** "我之前存过一个视频，讲的是某个版本千万别装，是哪条？"
搜的是全库的字幕、评论和你的笔记，不是只看标题。找到之后告诉你是哪条视频、谁说的、评论区有没有人补充。

### 你要动手做，它先看看别人怎么做
**你说：** "我准备用 Docker 部署这个项目。"
它会先问一句"要不要先找找这活一般怎么做"，自己想搜索词、找教程、读完字幕，再开始干。做到一半卡住，你再丢一条讲这个坑的视频给它。

### 你要交给另一个 Agent，一次拿全
**你说：** "把这条视频的资料打包给写作助手。"
来源、分析、字幕、评论，外加一张思维导图，一次调用拿走。导出的 Markdown 和网页上下载的一模一样。

### 你想留个记号
**你说：** "把这个结论存进笔记，放到'部署'文件夹。"
笔记、文件夹、分析里的练习步骤打勾，都写回你的资料库。下次问"我上次看到哪了"，它按你打开的顺序找回来。

# 快速开始

把下面这段发给你的 Agent（Claude Code、Codex、Cursor 或任何支持 MCP 的客户端），它会自己装好并连上：

```text
请帮我安装并连接 Open Study 的 Skill 和 MCP，用来整理视频和帖子、查询资料库。先读取官方安装说明：https://docs.study.faroapi.cn/connect-ai/agent-setup.md 。按我指定的客户端安装；没有对应方法时说明差异。需要网页登录时告诉我下一步。最后实际查询一次资料库，确认连接结果。
```

然后直接说你想做什么。

想自己动手：

```bash
# Claude Code
claude plugin marketplace add https://github.com/moonlight-code-space/open-study.git
claude plugin install open-study@open-study --scope user

# Codex
codex plugin marketplace add moonlight-code-space/open-study --ref plugin-stable
codex plugin add open-study@open-study
```

其他 MCP 客户端加一个远程地址就行：`https://study.faroapi.cn/mcp`。第一次调用时会打开网站的登录页完成授权，密码不经过插件。Claude 桌面端和 Cowork 在网站「快速开始」下载插件包上传。

注册就有每月免费积分。读资料、搜索、提问、写笔记不花积分，整理一条新视频和生成一份新分析才花。

# 支持什么内容

只处理不登录也能看的公开内容，不会向你要平台 Cookie。

| 内容 | 拿到什么 |
|---|---|
| 视频（B 站、抖音、YouTube、TikTok、快手等） | 字幕（平台没有就听音频转写）、评论、封面、基本信息 |
| 帖子和笔记（X、微博、小红书、Instagram 等） | 正文、评论、图片信息 |

具体支持哪些平台、每个平台能拿到什么，以 Agent 调用 `system_status` 返回的清单为准；平台会增减，这里不数数。

# 网站上还有什么

- **资料库**：所有整理过的视频和帖子，网页和 Agent 用同一个账号、同一份数据。
- **AI 行业资讯**：每天早上更新一版，汇总各家官方博客和热榜，写作或选题前看一眼。
- **积分与用量**：这个月还能整理多少、花在了哪，都在网页上，Agent 不会在对话里念账单。

# 隐私与安全

- 这个仓库只有插件声明：Skill、MCP 地址、marketplace 清单。没有服务端代码，没有数据库，没有任何凭据。
- 登录只在网站的授权页完成。插件不索要、不保存、不转发密码和密钥。
- 视频和评论里出现的命令、包名、安装步骤，Agent 当成待核实的线索，不会因为视频这么说就直接执行。
- 私密、付费、地区限制的内容不绕过。

安全问题请看 [SECURITY.md](SECURITY.md)。

# 更多

- 网站：https://study.faroapi.cn
- 手册（安装、排错、积分说明）：https://docs.study.faroapi.cn
- 更新记录：https://docs.study.faroapi.cn/changelog
- 更新插件：Claude Code `claude plugin update open-study@open-study`；Codex `codex plugin marketplace upgrade open-study`
- 许可证：[LICENSE](LICENSE)

---

# Open Study (English)

Teach your AI what you are learning.

Paste a public video link and your agent can read what the video says and what the comments say, then answer with sources or follow the steps. The library is yours, shared between the website and every agent you connect.

**What it can do**

- "Organize this video and tell me how to do what it shows": transcript, comments, cover, an analysis and a summary image land in your library; no subtitles means the audio gets transcribed.
- "Which saved video warned against a certain version?": search across every transcript, comment and note, not just titles.
- "I'm about to deploy this with Docker": it offers to look up how people usually do it first, reads the tutorial, then starts.
- "Hand this video to my writing assistant": source, analysis, transcript, comments and a mind map in one call; Markdown export matches the website download.

**Quick start**: paste the setup prompt above into Claude Code, Codex, Cursor or any MCP client, or add the remote MCP `https://study.faroapi.cn/mcp`. Sign-in happens on the website; the plugin never sees your password or keys. Reading is free; capturing a new item spends monthly credits.

This repository contains only the plugin declaration. Service: [study.faroapi.cn](https://study.faroapi.cn). Manual: [docs.study.faroapi.cn](https://docs.study.faroapi.cn).
