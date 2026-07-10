# 我的 IPTV 直播源维护说明

这个项目已经改成“个人配置优先”的方式：默认配置仍保留在 `config/config.ini`，你的个人设置放在 `config/user_config.ini`，频道菜单放在 `config/user_demo.txt`。

## 你的结果文件

- TXT 直播源：`output/my_iptv.txt`
- M3U 直播源：`output/my_iptv.m3u`
- 本机服务地址：`http://127.0.0.1:5180/txt`、`http://127.0.0.1:5180/m3u`

## 怎么变成自己的源

1. 如果使用 Anaconda，可以直接运行 `scripts/update-personal-conda.ps1`。如果使用普通 Python，建议安装 Python 3.13，并在安装界面勾选 `Add python.exe to PATH`。
2. 在 `config/user_demo.txt` 调整你想看的频道和分组。
3. 复制 `config/local/my_channels.example.txt` 为 `config/local/my_channels.txt`，再添加你自己有权使用的直播地址，格式是：

```text
频道名,直播地址
```

4. 公开订阅源放在 `config/subscribe.txt`，本地源会优先于订阅源。
5. 运行更新：

```powershell
.\scripts\update-personal.ps1
```

如果使用 Anaconda，运行：

```powershell
.\scripts\update-personal-conda.ps1
```

## 当前优化策略

- 本地源优先，订阅源补充。
- 每个频道最多保留 3 条可用线路，减少播放器列表膨胀。
- 开启测速、分辨率过滤、速度过滤和补偿机制，兼顾质量与不空源。
- 默认只生成 IPv4，兼容性更高；如果你的网络和播放器支持 IPv6，把 `config/user_config.ini` 里的 `ipv_type` 改成 `all`。
- 默认关闭 RTMP/HLS 推流，减少电脑或服务器 CPU 占用。

## 生成 IPv4 稳定版和 IPv6 高清版

运行：

```powershell
.\scripts\generate-personal-variants.ps1
```

会生成四个文件：

- IPv4 稳定版：`output/my_iptv_ipv4.txt`
- IPv4 稳定版 M3U：`output/my_iptv_ipv4.m3u`
- IPv6 版：`output/my_iptv_ipv6_hd.txt`
- IPv6 版 M3U：`output/my_iptv_ipv6_hd.m3u`

IPv6 版会强制使用 IPv6，默认 720P 起筛并开启补偿，以优先增加可用频道数量。如果当前宽带、路由器或播放器不支持 IPv6，结果可能无法播放。

GitHub Actions 也会每半小时自动生成这两套结果：

- IPv4 稳定版 M3U：`https://raw.githubusercontent.com/adcheun/iptv-api-master/main/output/my_iptv_ipv4.m3u`
- IPv6 版 M3U：`https://raw.githubusercontent.com/adcheun/iptv-api-master/main/output/my_iptv_ipv6_hd.m3u`

## 合规提醒

请只添加你有权使用、转发或观看的直播地址。这个仓库只是整理、测速和生成播放列表的工具，不负责提供节目内容授权。
