$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$RulesetDir = Join-Path $Root "ruleset"
New-Item -ItemType Directory -Force -Path $RulesetDir | Out-Null

$Base = "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta"

$Rules = @{
  "reject_domain.mrs"         = "$Base/geo/geosite/category-ads-all.mrs"
  "private_domain.mrs"        = "$Base/geo/geosite/private.mrs"
  "cn_domain.mrs"             = "$Base/geo/geosite/cn.mrs"
  "geolocation_not_cn.mrs"    = "$Base/geo/geosite/geolocation-!cn.mrs"
  "google_domain.mrs"         = "$Base/geo/geosite/google.mrs"
  "youtube_domain.mrs"        = "$Base/geo/geosite/youtube.mrs"
  "telegram_domain.mrs"       = "$Base/geo/geosite/telegram.mrs"
  "twitter_domain.mrs"        = "$Base/geo/geosite/twitter.mrs"
  "github_domain.mrs"         = "$Base/geo/geosite/github.mrs"
  "openai_domain.mrs"         = "$Base/geo/geosite/openai.mrs"
  "netflix_domain.mrs"        = "$Base/geo/geosite/netflix.mrs"
  "tiktok_domain.mrs"         = "$Base/geo/geosite/tiktok.mrs"
  "spotify_domain.mrs"        = "$Base/geo/geosite/spotify.mrs"
  "apple_domain.mrs"          = "$Base/geo/geosite/apple.mrs"
  "microsoft_domain.mrs"      = "$Base/geo/geosite/microsoft.mrs"
  "games_domain.mrs"          = "$Base/geo/geosite/category-games.mrs"
  "telegram_ip.mrs"           = "$Base/geo/geoip/telegram.mrs"
  "netflix_ip.mrs"            = "$Base/geo/geoip/netflix.mrs"
  "google_ip.mrs"             = "$Base/geo/geoip/google.mrs"
  "twitter_ip.mrs"            = "$Base/geo/geoip/twitter.mrs"
  "cn_ip.mrs"                 = "$Base/geo/geoip/cn.mrs"
  "private_ip.mrs"            = "$Base/geo/geoip/private.mrs"
}

foreach ($Name in $Rules.Keys | Sort-Object) {
  $Url = $Rules[$Name]
  $OutFile = Join-Path $RulesetDir $Name
  Write-Host "Downloading $Name"
  if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
    & curl.exe -L --retry 3 --retry-delay 2 --fail --output $OutFile $Url
    if ($LASTEXITCODE -ne 0) {
      throw "curl.exe failed to download $Url"
    }
  } else {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
  }
}

$IndexPath = Join-Path $Root "index.html"
$GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$ListItems = ($Rules.Keys | Sort-Object | ForEach-Object {
  "    <li><a href=""./ruleset/$($_)"">$($_)</a></li>"
}) -join "`n"

@"
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>lzamq rules mirror</title>
  <style>
    body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; line-height: 1.6; max-width: 920px; margin: 40px auto; padding: 0 20px; }
    code { background: #f4f4f5; padding: 2px 6px; border-radius: 6px; }
  </style>
</head>
<body>
  <h1>lzamq rules mirror</h1>
  <p>Generated at: <code>$GeneratedAt</code></p>
  <p>Use in Mihomo / Clash Meta rule-providers.</p>
  <ul>
$ListItems
  </ul>
</body>
</html>
"@ | Set-Content -LiteralPath $IndexPath -Encoding UTF8

Write-Host ""
Write-Host "Done. Upload this folder to Cloudflare Pages:"
Write-Host $Root
