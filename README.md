# Open Study

让 AI 学会你正在学习的事。

粘贴一条视频链接，你的 Agent 就能读到视频里讲了什么、评论区怎么说，然后带着出处回答你，或者照着做。

# Open Study 能干什么？

你把一条视频给它，它把视频读成你能用的东西。六种人，各举一件事：

**写代码的人**　"收藏夹里那条部署教程，够不够让同事打开我的页面？"
读完字幕和评论，告诉你教程走到哪一步、看的人卡在哪、有没有更省事的路。

**做视频的人**　"明天拍旧衣柜改造，开头几十秒起不来。"
找一条同题材的爆款，把开头拆成一拍一拍，标出哪段能借、哪段得回看原片。

**开网店的人**　"我要上一批瑜伽垫，买家最后会因为什么退货？"
读测评的口播和评论，把退货理由、真实购买动机、口播里对不上的话列出来。

**装修的人**　"水电师傅明天开槽，走天还是走地、电线几平方，我都答不上来。"
从四十分钟的长视频里把数收成一张表，再把评论区顶回来的三个问题一起给你。

**教书的人**　"要讲凸透镜成像，找一段真讲得明白的，顺便看学生卡在哪。"
拆出口诀怎么搭、学生反复卡住的几处、这条视频没讲到什么。

**学语言的人**　"全英开会，没听懂时怎么开口？库里那两条哪条真讲了？"
两条并排读，指出接话的句子在哪条、跟读课能补什么、先备熟哪两句。

每次它都会说清边界：字幕不分说话人，画面看不见，评论只是最热的一页。这些都是首页「场景」里的真视频、真问题。

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

- "I built a small HTML tool with AI. Is that deployment tutorial in my library enough to get it in front of a colleague?": it reads the transcript and comments, tells you how far the tutorial actually goes and where viewers got stuck.
- "I'm shooting a wardrobe makeover tomorrow and the opening won't come together": it breaks the opening of a high-view video into beats and compares two similar ones already saved.
- "Before I stock yoga mats, tell me why buyers end up returning them": it reads the review and its comments and lists the reasons before the first bad review arrives.
- "The electrician starts tomorrow and I can't answer a single question": it pulls the numbers out of a forty-minute walkthrough into one table and flags what the video shows but never says.
- Every answer states its limits: transcripts don't separate speakers, the picture is unseen, comments are the hottest page only.

**Quick start**: paste the setup prompt above into Claude Code, Codex, Cursor or any MCP client, or add the remote MCP `https://study.faroapi.cn/mcp`. Sign-in happens on the website; the plugin never sees your password or keys. Reading is free; capturing a new item spends monthly credits.

This repository contains only the plugin declaration. Service: [study.faroapi.cn](https://study.faroapi.cn). Manual: [docs.study.faroapi.cn](https://docs.study.faroapi.cn).
