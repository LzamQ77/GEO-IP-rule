from __future__ import annotations

import html
import time
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parent
RULESET_DIR = ROOT / "ruleset"
RULESET_DIR.mkdir(parents=True, exist_ok=True)

BASE = "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta"

RULES = {
    "reject_domain.mrs": f"{BASE}/geo/geosite/category-ads-all.mrs",
    "private_domain.mrs": f"{BASE}/geo/geosite/private.mrs",
    "cn_domain.mrs": f"{BASE}/geo/geosite/cn.mrs",
    "geolocation_not_cn.mrs": f"{BASE}/geo/geosite/geolocation-!cn.mrs",
    "google_domain.mrs": f"{BASE}/geo/geosite/google.mrs",
    "youtube_domain.mrs": f"{BASE}/geo/geosite/youtube.mrs",
    "telegram_domain.mrs": f"{BASE}/geo/geosite/telegram.mrs",
    "twitter_domain.mrs": f"{BASE}/geo/geosite/twitter.mrs",
    "github_domain.mrs": f"{BASE}/geo/geosite/github.mrs",
    "openai_domain.mrs": f"{BASE}/geo/geosite/openai.mrs",
    "netflix_domain.mrs": f"{BASE}/geo/geosite/netflix.mrs",
    "tiktok_domain.mrs": f"{BASE}/geo/geosite/tiktok.mrs",
    "spotify_domain.mrs": f"{BASE}/geo/geosite/spotify.mrs",
    "apple_domain.mrs": f"{BASE}/geo/geosite/apple.mrs",
    "microsoft_domain.mrs": f"{BASE}/geo/geosite/microsoft.mrs",
    "games_domain.mrs": f"{BASE}/geo/geosite/category-games.mrs",
    "telegram_ip.mrs": f"{BASE}/geo/geoip/telegram.mrs",
    "netflix_ip.mrs": f"{BASE}/geo/geoip/netflix.mrs",
    "google_ip.mrs": f"{BASE}/geo/geoip/google.mrs",
    "twitter_ip.mrs": f"{BASE}/geo/geoip/twitter.mrs",
    "cn_ip.mrs": f"{BASE}/geo/geoip/cn.mrs",
    "private_ip.mrs": f"{BASE}/geo/geoip/private.mrs",
}


def download(url: str, out_file: Path) -> None:
    req = urllib.request.Request(url, headers={"User-Agent": "lzamq-rules-sync/1.0"})
    last_error: Exception | None = None
    for attempt in range(1, 4):
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                data = resp.read()
            out_file.write_bytes(data)
            return
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            print(f"  attempt {attempt} failed: {exc}")
            time.sleep(2)
    raise RuntimeError(f"failed to download {url}") from last_error


for name, url in sorted(RULES.items()):
    print(f"Downloading {name}")
    download(url, RULESET_DIR / name)

items = "\n".join(
    f'    <li><a href="./ruleset/{html.escape(name)}">{html.escape(name)}</a></li>'
    for name in sorted(RULES)
)

(ROOT / "index.html").write_text(
    f"""<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>lzamq rules mirror</title>
  <style>
    body {{ font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; line-height: 1.6; max-width: 920px; margin: 40px auto; padding: 0 20px; }}
    code {{ background: #f4f4f5; padding: 2px 6px; border-radius: 6px; }}
  </style>
</head>
<body>
  <h1>lzamq rules mirror</h1>
  <p>Generated at: <code>{time.strftime("%Y-%m-%d %H:%M:%S %z")}</code></p>
  <p>Use in Mihomo / Clash Meta rule-providers.</p>
  <ul>
{items}
  </ul>
</body>
</html>
""",
    encoding="utf-8",
)

print()
print("Done. Upload this folder to Cloudflare Pages:")
print(ROOT)
