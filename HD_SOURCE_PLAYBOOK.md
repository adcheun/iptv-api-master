# 高清直播源获取和入库办法

这个项目只负责整理、测速和生成播放列表。请只添加你有权使用、转发或观看的直播地址。

## 优先找源方向

1. 官方公开直播：电视台官网、官方 App、官方新媒体平台公开的 m3u8。
2. 自有权益源：你家宽带 IPTV、校园网、酒店/公司内网 IPTV、自己购买的 M3U 服务。
3. IPv6 源：优先找明确标注 IPv6、移动/联通/电信 IPTV、m3u8、组播转单播的源。
4. 自建设备：电视盒子、采集卡、HDHomeRun、局域网转推服务，把合法信号转成 m3u8。

## 判断是不是高清

- 720P：最低可用，适合保底。
- 1080P：日常高清目标。
- 4K：要求高带宽，稳定源更少。
- 速度建议：1080P 至少 `0.5 M/s`，4K 至少 `1.0 M/s` 以上。

本项目已经在 workflow 里做了测速和分辨率过滤。你只需要不断补充候选源。

## 加入单条本地源

运行：

```powershell
.\scripts\add-local-source.ps1 -Channel "CCTV-1" -Url "http://example.com/live/cctv1.m3u8"
```

如果这个源是你确认稳定且有权使用的，可以加入白名单，跳过测速并优先保留：

```powershell
.\scripts\add-local-source.ps1 -Channel "CCTV-1" -Url "http://example.com/live/cctv1.m3u8" -Whitelist
```

本地源会写入：

```text
config/local/my_channels.txt
```

## 加入批量订阅源

把你有权使用的 txt/m3u 订阅地址加入：

```text
config/subscribe.txt
```

一行一个地址。

## 补频道模板

如果生成结果里出现 `♻️未匹配频道`，说明抓到了源，但频道名不在你的模板里。把这些频道名补进：

```text
config/user_demo.txt
```

或者把别名补进：

```text
config/alias.txt
```

格式：

```text
CCTV-1,央视一套,中央一台,CCTV1
```

## 查看哪些频道缺源

运行：

```powershell
.\scripts\audit-playlist-quality.ps1 -Playlist output/my_iptv_ipv4.m3u
```

数量少的频道优先补本地源或别名。

## 更新并上传

本地测试：

```powershell
.\scripts\update-personal-conda.ps1
```

提交到 GitHub 后，Actions 会每半小时自动重新筛选生成。
