# Open Study

**让 AI 学会你正在学习的事。**

Open Study 是一个视频证据库：把 B 站、抖音、X、TikTok、小红书、快手、微博、
YouTube、Instagram 九个平台的公开视频和帖子，整理成可检索、可引用的学习资料
——给人看，更给 AI agent 直接调用。

装上本插件后，你的 agent（Claude Code、Codex、Cursor、Cline、Gemini CLI 等
凡是支持 MCP 的客户端都可以）就能：

- **贴一条公开链接**，自动采集字幕、评论、封面和元数据进你的私有资料库；
- **按"谁说过这句话"搜**遍全库的字幕、评论和你自己的笔记，不只按标题找；
- **对一份资料直接提问**，答案有出处；结论可写回笔记、按主题建文件夹；
- **交给另一个 agent 时一次拿全**：来源、分析、字幕、评论，外加思维导图。

本仓库只包含插件声明（Skill、MCP 地址、marketplace 清单），**不包含**
Open Study 服务端、数据库、任何凭据或用户数据。服务在
[study.faroapi.cn](https://study.faroapi.cn)。

## 安装

### Claude Code

```bash
claude plugin marketplace add https://github.com/moonlight-code-space/open-study.git
claude plugin install open-study@open-study --scope user
```

`--scope user` 对本机所有项目生效；只想在当前仓库用就换成 `--scope project` 或 `--scope local`。
首次调用工具时在会话里输入 `/mcp` 完成网站登录授权。更新用
`claude plugin marketplace update open-study` 再 `claude plugin update open-study@open-study`。

### 其他客户端

任何支持 MCP 的客户端，直接添加远程 MCP：`https://study.faroapi.cn/mcp`
（首次调用会打开网站的正常登录授权，插件不经手密码）。

Codex 用户可走 marketplace 稳定通道（`plugin-stable` 分支）：

```bash
codex plugin marketplace add moonlight-code-space/open-study --ref plugin-stable --json
codex plugin add open-study@open-study --json
```

## 更新

```bash
codex plugin marketplace upgrade open-study --json
codex plugin add open-study@open-study --json
```

更新完让 agent 调一次 `open-study:system_status`，核对
`compatibility.latest_plugin_version` 与本地一致即可。网站控制台的
「快速开始」页另提供离线 zip 与校验值。

---

# Open Study (English)

**Teach your AI what you are learning.**

Open Study turns public videos and posts from nine platforms — Bilibili,
Douyin, X, TikTok, Xiaohongshu, Kuaishou, Weibo, YouTube, Instagram — into a
searchable, citable evidence library, built for humans to read and for AI
agents to call directly.

With this plugin, any MCP-capable client (Claude Code, Codex, Cursor, Cline,
Gemini CLI and more) can:

- **Paste one public link** and capture its transcript, comments, cover and
  metadata into your private library;
- **Search by what was actually said** across every saved transcript, comment
  and note — not just titles;
- **Ask questions about one saved material** and get grounded answers; write
  conclusions back as notes, organize by folders;
- **Hand a whole material to another agent in one call**: source, analysis,
  transcript, comments, plus a mind map.

This repository contains only the plugin declaration (Skill, remote MCP
endpoint, marketplace manifest). It does **not** contain the Open Study
server, database, credentials or any user data. The service lives at
[study.faroapi.cn](https://study.faroapi.cn).

**Install**: add the remote MCP `https://study.faroapi.cn/mcp` to any
MCP-capable client, or use the Codex marketplace commands above. Current
version: see Releases.
