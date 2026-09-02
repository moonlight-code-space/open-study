# Open Study

**让 AI 学会你正在学习的事。**

视频里的经验，你的 Agent 从此也读得到。粘贴一条链接，Open Study 把视频整理成它能直接引用的资料，先学习别人怎么干，再继续进行你的工作。

## 为什么需要它

真正有用的经验，很多只存在于视频里：一位老手录的教程、一次项目复盘、一场访谈里随口带过的坑。你看得懂，你的 Agent 看不了。它不认视频，也不认评论区里那句「别用这个版本」。

Open Study 补上这一段。你把链接丢给 Agent，它就能读到这条视频说了什么、评论区怎么反馈、别人是怎么把这件事做成的。答案带着出处，不是凭印象编的。整理过的资料存在你自己的资料库里，网页和 Agent 用同一个账号、同一份数据，下次接着用。

你看视频长见识，它看视频长本事。

## 怎么用

1. **粘贴链接。** B 站、抖音、YouTube 等平台的视频链接都认。看到有用的，直接丢进和 Agent 的对话里。
2. **派发任务。** "帮我了解这个项目""别人是怎么做的""下一步该用什么工具"，平常怎么说话，就怎么吩咐它。
3. **学以致用。** Open Study 把视频变成 Agent 读得懂的资料。它拿别人踩过的坑、跑通的做法来答你，答案带着出处。
4. **边干边学。** 项目卡在哪儿，就找条讲那件事的视频发给它。学完它自己接着干，不用你一步步教。

## 能拿到什么

只处理不登录也能看的公开内容，不需要、也不会向你要任何平台的 Cookie。

- **视频**：字幕、评论、封面和基本信息。平台没有字幕的，自动听音频转成文字。
- **帖子和笔记**：正文和评论。X、微博、小红书、Instagram 这类内容没有字幕，价值在帖子本身和大家的讨论里。
- 支持哪些平台、每个平台能拿到什么，以 Agent 调用 `system_status` 返回的清单为准。这份清单会随时间变，README 不替它数数。

## 装进 Agent 之后能做的事

- **贴一条链接，资料进库。** 字幕、评论、封面一次整理好，自动生成一份 AI 分析和一张可以分享的总结图。
- **按"谁说过这句话"搜。** 搜的是全库的字幕、评论和你自己的笔记，半句记得的原话也能翻出来，不只按标题找。
- **对一份资料直接提问。** "这个视频里那个报错他是怎么解决的"，答案来自这份资料，不另收费。
- **一次拿全。** 把一条视频的来源、分析、字幕、评论和思维导图打包交给另一个 Agent，一次调用。
- **结论留下来。** 写进这份资料的笔记，按主题建文件夹，分析给出的操作步骤可以逐条打勾，做到哪一步一目了然。
- **导出。** 一份资料导成 Markdown，跟网页上下载的一模一样，拿去别的工具接着用。
- **接着上次读。** 问 Agent "我上次看到哪了"，它按你打开的顺序找回来，连阅读位置一起。
- **先学再干。** 你要开始做一件事，它会先问一句"要不要先看看这活一般怎么做"，自己想搜索词、自己找教程、读完再动手。
- **AI 行业资讯。** 网站上每天早上更新一版 AI 行业资讯板，汇总官方博客和热榜，写作或选题前先看一眼。

## 几个具体的用法

**做 Agent 的开发者，选工具。** "对比一下适合 Agent 工作流的搜索工具，看看别人实际怎么接的。"Agent 找到几条相关的实测视频，整理进库，把每个工具在视频里的评价、踩过的坑和评论区的反馈列成一张表，附上出处。

**产品经理，找机会。** 把几条同类产品的评测视频丢进去，问"用户在抱怨什么"。Agent 从评论区和字幕里把痛点归成几类，每一类给出原话和视频来源，而不是一段泛泛的总结。

**内容创作者，定选题。** "这周各平台关于 X 的讨论，有什么值得做成视频的角度？"Agent 用库里已有的资料和评论热度找切入点，把结论写进笔记，下次打开就在。

**学习一门新技术，卡住了。** 部署到一半报错，找一条讲这个问题的视频发过去："照这个视频的做法帮我过一下。"它读完字幕，对照你的报错，把该改的地方列出来，然后接着干。

## 安装（一分钟）

最省事的办法：把[手册首页](https://docs.study.faroapi.cn/)那段安装提示词发给你的 Agent，它会自己装好并连上。想自己动手，Open Study 的资料库通过 MCP 提供，任何支持 MCP 的 Agent 都能接：

- **任何 MCP 客户端**：添加远程 MCP `https://study.faroapi.cn/mcp`。第一次调用时会打开网站的登录页完成授权，密码不经过插件。
- **Claude Code**：

  ```bash
  claude plugin marketplace add https://github.com/moonlight-code-space/open-study.git
  claude plugin install open-study@open-study --scope user
  ```

- **Codex**：

  ```bash
  codex plugin marketplace add moonlight-code-space/open-study --ref plugin-stable
  codex plugin add open-study@open-study
  ```

- **Claude 桌面端与 Cowork**：在网站「快速开始」下载插件包上传即可。

更新：Claude Code 用 `claude plugin update open-study@open-study`，Codex 用 `codex plugin marketplace upgrade open-study`。其他情况、离线安装和排错，看[使用手册](https://docs.study.faroapi.cn/)。

注册即领每月免费积分，网页与 Agent 同步可用。读库、搜索、提问、写笔记都不花积分；整理一条新视频和生成一份新分析才会。

## 隐私与安全

- 这个仓库只有插件声明：Skill、MCP 地址、marketplace 清单。不含服务端代码、数据库、任何凭据或用户数据。
- 登录只走网站的授权页。插件从不索要、保存或转发密码和密钥。
- 只整理公开内容。私密、付费、地区限制的内容不会绕过。
- 视频和评论里出现的命令、包名、安装步骤，Agent 会当作待核实的线索，不会因为视频这么说就直接执行。

发现安全问题请看 [SECURITY.md](SECURITY.md)。

## 链接

- 网站：https://study.faroapi.cn
- 使用手册：https://docs.study.faroapi.cn
- 更新记录：https://docs.study.faroapi.cn/changelog
- 许可证：见 [LICENSE](LICENSE)

---

# Open Study (English)

**Teach your AI what you are learning.**

The know-how in a video is invisible to your agent. Open Study fixes that: paste a public link, and the video becomes material the agent can read and cite, including the transcript, the comments and a stored analysis. The library is yours, shared between the website and every agent you connect.

**With the plugin, an agent can**

- capture a link into your library (transcript, comments, cover, an analysis and a shareable summary image);
- search by what was actually said, across every transcript, comment and note;
- ask questions about one saved item and get grounded answers, for free;
- hand a whole item to another agent in one call, mind map included;
- keep conclusions as notes, group items into folders, tick off practice steps, export Markdown;
- pick up where you left off, and look up how a job is usually done before starting it;
- read a daily AI industry digest on the website.

**Install**: add the remote MCP `https://study.faroapi.cn/mcp` to any MCP-capable client. Claude Code and Codex users can use the marketplace commands above. Sign-in happens on the website; the plugin never handles your password or keys.

This repository holds only the plugin declaration. The service lives at [study.faroapi.cn](https://study.faroapi.cn); the manual is at [docs.study.faroapi.cn](https://docs.study.faroapi.cn).
