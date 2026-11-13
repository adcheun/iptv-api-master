# 我的 IPTV 维护说明

本仓库以 `Guovin/iptv-api` v3 的 `master` 分支为底座，核心代码不做个人化
修改。个人内容集中在 `config/user_config.ini`、`config/user_demo.txt`、
`config/local/`、订阅列表和 `personal-update.yml`，便于以后继续同步上游。

## 自动更新

GitHub Actions 每天北京时间/新加坡时间 12:00 运行（UTC 04:00），也可在
Actions 页面手动触发。工作流使用 Python 3.14，生成：

- `output/my_iptv.txt`、`output/my_iptv.m3u`（双栈主力推荐版）
- `output/my_iptv_ipv4.txt`、`output/my_iptv_ipv4.m3u`（纯 IPv4 兼容版）
- `output/my_iptv_ipv6_hd.txt`、`output/my_iptv_ipv6_hd.m3u`（纯 IPv6 1080P/4K 超清极速版）
- 兼容路径 `output/result.*`、`output/ipv4/result.*`、`output/ipv6/result.*`
- `output/epg/epg.xml` 与 `output/epg/epg.gz`（电子节目单预告）

## 频道分类结构

在 `config/user_demo.txt` 中已构建标准 9 大板块分类：
1. 📌 我的常看（核心大台快速直达）
2. 📺 央视频道（CCTV-1~17、4K、CETV、CGTN 全套）
3. 📡 全国卫视（主流一线卫视全覆盖）
4. 🏀 体育赛事（央视体育、地方体育、台球垂钓等专业赛事专区）
5. 🎞️ 影视剧场（央视电影、CHC 系列动作/家庭/影迷专区）
6. 👶 少儿动漫（少儿、金鹰卡通、卡酷、优漫、嘉佳卡通专区）
7. ☘️ 湖北专区（湖北卫视、湖北综合、湖北经视、湖北影视、武汉新闻等）
8. ☘️ 粤语专区（广东珠江、大湾区卫视、广州综合等粤语精品）
9. 🌏 港澳华语（香港卫视、凤凰卫视等华语频道）

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
