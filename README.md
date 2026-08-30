# Open Study for Codex

Open Study 是一个「视频证据库」：把 B 站、抖音、X、TikTok、小红书、快手、微博、
YouTube、Instagram 的公开视频和帖子整理成可检索的学习资料，给人看，更给 AI
agent 直接调用。装上这个插件后，你的 agent 就能：

- 贴一条公开链接，自动采集字幕、评论、封面和元数据进你的私有资料库；
- 按标题找资料，也按「谁说过这句话」搜遍全库的字幕、评论和你的笔记；
- 把结论写回资料的笔记、按主题建文件夹，下次打开网站就在那儿；
- 给另一个 agent 或工作流时，一次调用拿到整条内容外加思维导图。

本仓库只包含 Codex marketplace 声明、Skill 和远程 MCP 地址，不包含 Open Study
服务端、数据库、任何凭据或用户数据。

## 安装

稳定通道是 `plugin-stable` 分支：

```bash
codex plugin marketplace add moonlight-code-space/open-study-codex-plugin \
  --ref plugin-stable --json
codex plugin add open-study@open-study --json
```

装好后新开一个 Codex 会话。首次调用会走网站的正常登录授权，插件不经手密码，
也永远不要把访问令牌粘贴进对话。

## 更新

```bash
codex plugin marketplace upgrade open-study --json
codex plugin add open-study@open-study --json
```

更新完让 agent 调一次 `open-study:system_status`，核对
`compatibility.latest_plugin_version` 与本地版本一致即可。

## 版本

当前：v0.8.1。变更记录见 git 标签；网站控制台的「快速开始」页提供离线 zip
下载与校验值。
