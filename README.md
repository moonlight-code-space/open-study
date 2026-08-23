# Open Study for Codex

Open Study turns a public Bilibili link into saved learning material, then lets
Codex answer from the video's metadata, transcript and selected comments.

This repository contains only the Codex marketplace, Skill and remote MCP
declaration. It does not contain the Open Study server, database, provider
credentials or user data.

## Install

The stable channel is the `plugin-stable` branch:

```bash
codex plugin marketplace add moonlight-code-space/open-study-codex-plugin \
  --ref plugin-stable --json
codex plugin add open-study@open-study --json
```

Then start a new Codex task. The first Open Study tool use asks you to sign in
to your Open Study account through OAuth. After authorization, send a public
Bilibili URL or BV number and ask Codex to collect, summarize or study it.

## Update

```bash
codex plugin marketplace upgrade open-study --json
codex plugin add open-study@open-study --json
```

Start a new Codex task after updating so the refreshed Skill and MCP definition
are loaded.

## Current scope

- Public Bilibili video URLs and BV numbers
- Metadata, subtitles when available, selected comments and archived cover
- One user-authorized initial capture followed by polling for the final result
- Existing Open Study library search and evidence reading

The plugin does not import browser cookies, proxy settings or local files. The
remote service remains responsible for authentication, tenant isolation,
rate limits and billing.

## Version and support

The current plugin version is `0.5.0`. The remote service is
`https://study.faroapi.cn/mcp`.

This repository is a distribution channel, not an open-source release of the
Open Study backend. See [LICENSE](LICENSE).
