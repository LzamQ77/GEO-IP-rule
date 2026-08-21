# Cloudflare Pages 规则镜像

这个目录用于托管 Mihomo / Clash Meta 的 `.mrs` 规则文件。

## 使用方法

1. 在本机运行，优先用 Python 版本：

   ```powershell
   python .\sync-rules.py
   ```

   如果你想用 PowerShell 版本，也可以：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\sync-rules.ps1
   ```

2. 登录 Cloudflare Pages，创建 Direct Upload 项目。
3. 上传整个 `cloudflare-rules-mirror` 文件夹。
4. 得到 Pages 域名后，把 XBoard 模板里的规则 URL 改成：

   ```yaml
   url: "https://你的项目.pages.dev/ruleset/cn_domain.mrs"
   ```

## 注意

- `.mrs` 适合 Mihomo / Clash Meta，不适合老版 Clash。
- 如果 OpenClash 太老，请先升级 OpenClash 内核到 Mihomo。

## 自动更新方案

这个目录已经内置 GitHub Actions：

```text
.github/workflows/sync-rules.yml
```

把本目录上传到一个 GitHub 仓库后，它会：

1. 每天北京时间 04:20 自动运行 `sync-rules.py`。
2. 下载最新 `.mrs` 规则。
3. 如果规则文件有变化，自动提交到仓库。
4. Cloudflare Pages 绑定该仓库后，会因新提交自动重新部署。

Cloudflare Pages 设置建议：

```text
框架预设：无 / None
构建命令：留空；如果后台必须填，填 exit 0
构建输出目录：/；如果后台不接受 /，填 .
```
