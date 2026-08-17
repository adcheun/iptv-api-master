# 高清直播源维护办法

本项目只整理、测速并生成播放列表。请只添加你有权使用、转发或观看的地址。

- 优先使用电视台官方公开直播、自有 IPTV 权益源或自建设备输出。
- 1080p 建议至少 `0.5 MB/s`；4K 通常需要更高且更稳定的带宽。
- 私有或带凭据的订阅不要提交到公开仓库，可改用 GitHub Secrets 后再扩展工作流。
- 本地源放入 `config/local/my_channels.txt`，公开订阅放入
  `config/subscribe.txt`，频道别名放入 `config/alias.txt`。
- 若频道缺失，先检查频道名是否出现在 `config/user_demo.txt`，再检查别名和
  黑名单，最后补充合法候选源。

工作流每天仅筛选一次，运行完成后可从仓库 `output/` 获取 TXT、M3U 和 EPG。
