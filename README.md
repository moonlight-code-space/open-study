# Open Study

让 AI 学会你正在学习的事。

粘贴一条视频链接，你的 Agent 就能读到视频里讲了什么、评论区怎么说，然后带着出处回答你，或者照着做。

# Open Study 能干什么？

下面六段都是首页「场景」里的真实用法：真视频、真评论、真问题。你说一句话，Agent 交回来的是一份能直接用的东西。

### 写代码的人：一条部署教程够不够走完
**你说：** "我用 AI 写了个 HTML 小工具，想发给同事看。收藏夹里那条部署教程，够不够走完？"
它把那条两分钟的教程收进库，通读字幕和评论，告诉你正文走到了哪一步、评论区卡在哪、有人补了哪几条别的路，最后提醒你链接发出去前自己先发一条试。

### 做视频的人：开头那几十秒怎么起
**你说：** "明天开拍旧衣柜改造，开头几十秒起不来。找一条同题材播放高的收进来，把开头拆开给我看。"
它把开头拆成一拍一拍的顺序，对照库里另外两条同题材视频的头几句，说清哪一段能照搬、哪一段得回看原片，再把评论区追着问的那件事标出来。

### 开网店的人：差评在上架前就写好了
**你说：** "我打算上一批瑜伽垫，想先知道买家最后会因为什么退货，别等差评堆上来才反应过来。"
它读完那条测评的口播和评论，列出买家事后卡在哪、买垫子其实为了什么、口播里哪句和高赞评论对不上，让你上架前就知道差评会从哪来。

### 装修的人：明天开槽前的水电清单
**你说：** "水电师傅说明天就开槽，让我今天定走天还是走地、电线买几平方，我一个都答不上来。"
它从一条四十多分钟的水电长视频里把能拿到的数收拢成一张表，标出口播提到但字幕带不出来的几处，再把评论区顶回来的三个问题一起给你，明天站到工地上能对得上话。

### 教书的人：一节透镜课的讲法拆解
**你说：** "接下来要讲凸透镜成像规律，班上一半人靠死背表格，想找一段真讲得明白的，顺带看看学生卡在哪。"
它找到那条讲得最清楚的，拆出口诀是怎么搭起来的、评论里学生反复卡住的几件事、哪几处需要你自己再核，并说明这条没讲到光路作图。

### 学语言的人：英文会上怎么接话
**你说：** "组里改成全英开会了，最怕的是没听懂时怎么开口，库里那两条会议英语哪条真讲了这个？"
它把两条并排读一遍，告诉你卡住时怎么接话在哪条里、跟读课能补上什么、可用的部分有多长，最后建议先把"答不上来"和"没听懂"两句备熟。

每一段的边界它都会说清：字幕不分说话人、画面看不见、评论只是最热的一页。你拿到的是资料和判断，不是编出来的答案。

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
