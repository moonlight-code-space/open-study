// The clipper deliberately knows nothing: it reads the active tab's URL only
// after the user clicks the toolbar icon (activeTab), recognises a public
// content page on a platform Open Study accepts, and hands over the content
// id it parsed — never the raw URL. Sign-in, pricing, and the final
// confirmation all stay on the website.

const OPEN_STUDY_ORIGIN = "https://study.faroapi.cn";

// Mirrors backend/bilistudy/platform_registry.py and web/src/platforms.ts.
// Adding a platform means adding a row in all three places. `prefix` is the
// content-id prefix; Bilibili keeps its bare BV ids.
const PLATFORMS = [
  {
    prefix: "",
    label: "B 站",
    hosts: ["bilibili.com"],
    shortHosts: ["b23.tv"],
    id: [/(BV[0-9A-Za-z]{10})(?![0-9A-Za-z])/],
  },
  {
    prefix: "dy",
    label: "抖音",
    hosts: ["douyin.com", "iesdouyin.com"],
    shortHosts: ["v.douyin.com"],
    id: [/\/(?:video|note|share\/video)\/(\d{15,21})/],
  },
  {
    prefix: "x",
    label: "X",
    hosts: ["x.com", "twitter.com", "mobile.twitter.com"],
    shortHosts: ["t.co"],
    id: [/\/(?:i\/)?(?:[A-Za-z0-9_]{1,20}\/)?status(?:es)?\/(\d{8,25})/],
  },
  {
    prefix: "tt",
    label: "TikTok",
    hosts: ["tiktok.com"],
    shortHosts: ["vm.tiktok.com", "vt.tiktok.com"],
    id: [/\/(?:@[^/]+\/)?(?:video|photo)\/(\d{15,21})/],
  },
  {
    prefix: "xhs",
    label: "小红书",
    hosts: ["xiaohongshu.com"],
    shortHosts: ["xhslink.com"],
    id: [/\/(?:explore|discovery\/item)\/([0-9a-f]{24})/],
  },
  {
    prefix: "ks",
    label: "快手",
    hosts: ["kuaishou.com"],
    shortHosts: ["v.kuaishou.com"],
    id: [/\/short-video\/([0-9A-Za-z_-]{6,24})/],
  },
  {
    prefix: "wb",
    label: "微博",
    hosts: ["weibo.com", "weibo.cn", "m.weibo.cn"],
    shortHosts: [],
    id: [/\/detail\/(\d{10,20})/, /\/\d{5,12}\/([0-9A-Za-z]{8,12})(?![0-9A-Za-z])/],
  },
  {
    prefix: "yt",
    label: "YouTube",
    hosts: ["youtube.com"],
    shortHosts: [],
    id: [/(?:[?&]v=|\/shorts\/|\/embed\/|\/live\/)([0-9A-Za-z_-]{11})(?![0-9A-Za-z_-])/],
  },
  {
    // youtu.be is YouTube's short host but carries the real id in its path,
    // so it resolves locally instead of needing a redirect.
    prefix: "yt",
    label: "YouTube",
    hosts: ["youtu.be"],
    shortHosts: [],
    id: [/^\/([0-9A-Za-z_-]{11})(?![0-9A-Za-z_-])/],
  },
  {
    prefix: "ig",
    label: "Instagram",
    hosts: ["instagram.com"],
    shortHosts: [],
    id: [/\/(?:p|reel|reels)\/([0-9A-Za-z_-]{5,20})/],
  },
];

function hostMatches(hostname, candidates) {
  return candidates.some(
    (host) => hostname === host || hostname.endsWith("." + host),
  );
}

/** What the active tab points at: a content id, a short link, or nothing. */
function readTab(rawUrl) {
  let parsed;
  try {
    parsed = new URL(rawUrl);
  } catch {
    return { state: "unknown" };
  }
  if (parsed.protocol !== "https:" && parsed.protocol !== "http:") {
    return { state: "unknown" };
  }
  const hostname = parsed.hostname.toLowerCase().replace(/\.$/, "");
  // Short hosts first: v.douyin.com would otherwise match douyin.com's
  // suffix and fall through the id patterns into a rejection.
  for (const platform of PLATFORMS) {
    if (hostMatches(hostname, platform.shortHosts)) {
      return { state: "short", label: platform.label };
    }
  }
  for (const platform of PLATFORMS) {
    if (!hostMatches(hostname, platform.hosts)) continue;
    // Watch ids live in the query, most ids in the path; search both.
    const target = parsed.pathname + parsed.search;
    for (const pattern of platform.id) {
      const match = pattern.exec(target);
      if (!match) continue;
      const nativeId = match.slice(1).find(Boolean);
      if (!nativeId) continue;
      return {
        state: "ready",
        label: platform.label,
        nativeId,
        contentId: platform.prefix ? platform.prefix + ":" + nativeId : nativeId,
      };
    }
    return { state: "wrong-page", label: platform.label };
  }
  return { state: "unknown" };
}

const pageLabel = document.getElementById("page");
const sendButton = document.getElementById("send");

chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
  const tab = tabs && tabs[0];
  const found = readTab(tab && typeof tab.url === "string" ? tab.url : "");
  if (found.state === "short") {
    pageLabel.textContent =
      "这是一条" + found.label + "短链接。等它跳到正式页面再点，或把链接直接粘到工作台。";
    return;
  }
  if (found.state === "wrong-page") {
    pageLabel.textContent = "当前不是" + found.label + "的内容页。打开一条具体内容再点这里。";
    return;
  }
  if (found.state !== "ready") {
    pageLabel.textContent =
      "当前页面不在支持的平台上。打开一条公开的视频或帖子页面再点这里。";
    return;
  }
  pageLabel.textContent = found.label + "：" + found.nativeId;
  sendButton.disabled = false;
  sendButton.addEventListener("click", () => {
    const target =
      OPEN_STUDY_ORIGIN + "/?capture=" + encodeURIComponent(found.contentId) + "#top";
    chrome.tabs.create({ url: target });
    window.close();
  });
});
