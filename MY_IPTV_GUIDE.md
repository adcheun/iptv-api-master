# 我的 IPTV 维护说明

本仓库以 `Guovin/iptv-api` v3 的 `master` 分支为底座，核心代码不做个人化
修改。个人内容集中在 `config/user_config.ini`、`config/user_demo.txt`、
`config/local/`、订阅列表和 `personal-update.yml`，便于以后继续同步上游。

## 自动更新

GitHub Actions 每天北京时间/新加坡时间 12:00 运行（UTC 04:00），也可在
Actions 页面手动触发。工作流使用 Python 3.14，生成：

- `output/my_iptv.txt`、`output/my_iptv.m3u`
- `output/my_iptv_ipv4.txt`、`output/my_iptv_ipv4.m3u`
- `output/my_iptv_ipv6_hd.txt`、`output/my_iptv_ipv6_hd.m3u`
- 兼容路径 `output/result.*`、`output/ipv4/result.*`、`output/ipv6/result.*`
- `output/epg/epg.xml` 与 `output/epg/epg.gz`（成功生成时）

工作流只提交上述播放列表和 EPG。日志、缓存、数据库、WAL/SHM、截图及
其他运行状态均被排除。

## 修改个人内容

1. 在 `config/user_demo.txt` 调整频道和分组。
2. 将 `config/local/my_channels.example.txt` 复制为 `my_channels.txt`，加入
   自己有权使用的直播地址，格式为 `频道名,直播地址`。
3. 在 `config/subscribe.txt` 维护公开订阅，在 `config/epg.txt` 维护 EPG。
4. 在 `config/user_config.ini` 修改质量、数量和网络偏好。

当前采用稳定优先策略：每个频道最多保留 3 条线路，1080p 不足时允许
720p 保底，并启用补偿模式以减少空频道。新增订阅源应一次只加一个，观察
结果中的主机分布和实际播放质量，避免大列表造成重复与测速时间膨胀。

只添加你有权使用、转发或观看的直播地址。

## 同步上游

```bash
git fetch upstream
git switch -c upgrade-v3-next upstream/master
# 仅重新叠加上述个人文件，测试后再合入 main
```

上游代码与许可证均采用 AGPL-3.0；分发修改版本或通过网络提供服务时，应
遵守仓库 `LICENSE` 的相应源代码提供义务。
