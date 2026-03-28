# Alpha Hunter 🎯

自动追踪 Twitter KOL，挖掘早期 Alpha 项目的智能工具。

[![GitHub stars](https://img.shields.io/github/stars/ynbtc/alpha?style=social)](https://github.com/ynbtc/alpha/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🚀 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/ynbtc/alpha.git
cd alpha

# 运行安装脚本
./install.sh
```

### 配置环境变量

```bash
# Twitter 认证（必需）
export TWITTER_AUTH_TOKEN="your_auth_token"
export TWITTER_CT0="your_ct0"

# Frontrun.pro API（必需）
export FRONTRUN_API_KEY="your_api_key"

# Telegram 推送（可选）
export TELEGRAM_BOT_TOKEN="your_bot_token"
export TELEGRAM_CHAT_ID="your_chat_id"
```

> 💡 **获取 Twitter Cookie**: 登录 x.com → F12 → Application → Cookies → 复制 `auth_token` 和 `ct0`

### 运行

```bash
# 一键运行
alpha-hunter run-all

# 单独功能
alpha-hunter scan-tweets       # 扫描推文
alpha-hunter check-following   # 检查关注列表
alpha-hunter report            # 生成报告
```

---

## 📋 功能特性

### 1. 推文监控 📱
- **监控 14+ 位 KOL 的每日推文**
- **自动提取提及的项目推特**（@用户名、URL链接、短链解析）
- **增强关键词匹配**：
  - 项目相关：`Project`、`𝗣𝗿𝗼𝗷𝗲𝗰𝘁`、`project`、`protocol`、`platform`
  - 启动相关：`launch`、`launching`、`launched`、`presale`、`ido`
  - NFT相关：`nft`、`NFT`、`mint`、`free mint`
  - 测试网：`testnet`、`mainnet`、`devnet`
  - 空投：`airdrop`、`drop`、`reward`
  - 账户：`Accounts`、`account`、`wallet`
  - 其他：`alpha`、`gem`、`whitelist`、`staking`、`tokenomics`

### 2. 关注追踪 👥
- 追踪 10+ 位 KOL 的关注列表
- 识别新增关注项目
- 发现早期 Alpha 机会

### 3. KOL 验证 ✅
- 通过 Frontrun.pro API 验证项目
- KOL 关注数 >= 3 才记录
- 自动过滤低质量项目

### 4. 智能过滤 🧹
- 自动排除 KOL 个人账号
- 过滤已发币/知名老项目
- 去除研究员/交易员等噪音

### 5. 中文报告 🇨🇳
- 自动生成中文项目报告
- Telegram 自动推送
- Markdown 格式导出

---

## 🛠️ 自定义配置

编辑 `config.yaml`:

```yaml
# 推文监控博主
tweet_watchlist:
  - leakmealpha
  - BR4ted
  - zacxbt
  # 添加更多...

# 关注列表监控
following_watchlist:
  - _GuarEmperor
  - 0xtiao
  # 添加更多...

# 排除列表（老项目/KOL）
excluded_projects:
  - Cointelegraph
  - Pumpfun
  # 添加更多...
```

---

## 📊 输出示例

```
📊 今日热门项目 (2026-03-28)
共27个新项目

1、项目名称：Surgexyz_
项目推特：https://x.com/Surgexyz_
项目介绍：下一代创业公司发现层，专注AI独角兽孵化
KOL关注数：133⭐

2、项目名称：fair_vc
项目推特：https://x.com/fair_vc
项目介绍：基于多智能体系统构建的风险投资基金
KOL关注数：93⭐

...
```

---

## ⏰ 定时任务

### 每天自动运行

```bash
# 编辑 crontab
crontab -e

# 添加（每天 8:00 和 20:00 运行）
0 8,20 * * * /usr/local/bin/alpha-hunter run-all >> /var/log/alpha-hunter.log 2>&1
```

### OpenClaw 自动推送

```bash
openclaw cron add \
  --name "alpha-hunter-morning" \
  --cron "0 8 * * *" \
  --message "alpha-hunter run-all" \
  --channel telegram
```

---

## 📁 文件结构

```
alpha/
├── alpha-hunter.sh          # 主脚本
├── SKILL.md                 # Skill 文档
├── README.md                # 本文件
├── install.sh               # 安装脚本
├── config.yaml.template     # 配置模板
├── .gitignore              # Git 忽略规则
├── data/                   # 数据目录
│   ├── tweets/            # 推文数据
│   ├── following/         # 关注列表
│   └── projects/          # 项目数据库
└── reports/               # 输出报告
```

---

## 🔒 隐私保护

- ✅ 所有敏感信息通过环境变量传入
- ✅ 不硬编码任何个人凭证
- ✅ 历史记录本地存储，不上传云端
- ✅ `.gitignore` 自动排除敏感文件

---

## 🐛 常见问题

### Q: Twitter 认证失败？
A: 确保 `TWITTER_AUTH_TOKEN` 和 `TWITTER_CT0` 正确设置，且 Token 未过期。

### Q: 没有找到项目？
A: 检查 KOL 列表是否配置正确，或尝试扩大关键词范围。

### Q: 如何添加新的 KOL？
A: 编辑 `config.yaml` 中的 `tweet_watchlist` 和 `following_watchlist`。

### Q: 报告中的项目太多？
A: 调整 `min_kol_count` 阈值，或添加更多项目到 `excluded_projects`。

---

## 🤝 贡献

欢迎提交 Issue 和 PR！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📜 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [Frontrun.pro](https://frontrun.pro) - KOL 关注数据
- [twitter-cli](https://github.com/public-clis/twitter-cli) - Twitter 工具
- [OpenClaw](https://openclaw.ai) - Agent 平台

---

## 📮 联系

- Twitter: [@yn_btc](https://x.com/yn_btc)
- GitHub: [@ynbtc](https://github.com/ynbtc)

如果这个项目帮到了你，给个 ⭐ 吧！
