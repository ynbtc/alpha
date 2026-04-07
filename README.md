# 🎯 Alpha Hunter

> 自动追踪 Twitter KOL，挖掘早期 Alpha 项目的智能工具

[![GitHub stars](https://img.shields.io/github/stars/ynbtc/alpha?style=social)](https://github.com/ynbtc/alpha/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenClaw](https://img.shields.io/badge/Built%20for-OpenClaw-blue)](https://openclaw.ai)

---

## ✨ 核心功能

### 📱 推文监控
自动扫描 Twitter 上的早期项目信号：

| 监控维度 | 说明 |
|---------|------|
| **KOL 推文** | 15+ 位核心 KOL 的每日推文 |
| **@提及提取** | 自动识别推文中的 @项目账号 |
| **引用/转发** | 提取引用推文和转发的原作者 |

### 👥 关注追踪
监控 KOL 的关注动态，发现新增项目：
- **35+ 位核心 KOL** 关注列表监控
- 每日对比，识别新增关注
- 记录关注时间，判断入场时机

### ✅ KOL 验证
通过 [Frontrun.pro](https://frontrun.pro) API 验证项目质量：
- **KOL 关注数 ≥ 3** 才记录
- 自动过滤低质量项目
- 数据驱动的项目筛选

### 🧹 智能过滤
自动排除噪音，聚焦优质项目：

| 过滤类型 | 示例 |
|---------|------|
| **KOL 账号** | 研究员、交易员、分析师 |
| **老项目** | Cointelegraph、Pumpfun、OpenSea |
| **公链/协议** | Ethereum、Solana、Uniswap |
| **媒体平台** | CoinDesk、TheBlock |

### 🇨🇳 中文报告
自动生成中文项目报告：
- 项目名称 + Twitter 链接
- 中文项目介绍（从 Bio 提取）
- KOL 关注数统计
- 来源标注（推文提及 / 新增关注）

---

## 🚀 快速开始

### 1. 安装

```bash
# 克隆仓库
git clone https://github.com/ynbtc/alpha.git
cd alpha

# 运行安装脚本
./install.sh
```

### 2. 配置环境变量

```bash
# Twitter 认证（必需）
export TWITTER_AUTH_TOKEN="your_auth_token"
export TWITTER_CT0="your_ct0"

# Frontrun.pro API（必需）
export FRONTRUN_API_KEY="your_api_key"
```

> 💡 **获取 Twitter Cookie**：
> 1. 登录 [x.com](https://x.com)
> 2. F12 打开开发者工具 → Application → Cookies
> 3. 复制 `auth_token` 和 `ct0` 的值

### 3. 运行

```bash
# 一键运行全部
alpha-hunter run-all

# 单独功能
alpha-hunter scan-tweets       # 仅扫描推文
alpha-hunter check-following   # 仅检查关注列表
alpha-hunter report            # 生成报告
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
来源：[新增关注] @zacxbt

2、项目名称：fair_vc
项目推特：https://x.com/fair_vc
项目介绍：基于多智能体系统构建的风险投资基金
KOL关注数：93⭐
来源：[推文提及] @leakmealpha
```

---

## ⚙️ 自定义配置

编辑 `config.yaml`：

```yaml
# 推文监控 KOL 列表
tweet_watchlist:
  - leakmealpha
  - BR4ted
  - zacxbt

# 关注列表监控
following_watchlist:
  - _GuarEmperor
  - 0xtiao
  - zacxbt

# 排除列表（老项目/KOL）
excluded_projects:
  - Cointelegraph
  - Pumpfun
  - Uniswap
```

---

## ⏰ 定时任务

```bash
# 编辑 crontab
crontab -e

# 每天 8:00 和 20:00 运行
0 8,20 * * * /usr/local/bin/alpha-hunter run-all >> /var/log/alpha-hunter.log 2>&1
```

---

## 📁 项目结构

```
alpha/
├── alpha-hunter.sh          # 主脚本（核心逻辑）
├── SKILL.md                 # Skill 文档
├── README.md                # 本文件
├── install.sh               # 安装脚本
├── config.yaml.template     # 配置模板
├── .gitignore               # Git 忽略规则
├── data/                    # 数据目录（自动创建）
│   ├── tweets/             # 原始推文数据
│   ├── following/          # 关注列表快照
│   └── projects/           # 项目数据库
└── reports/                 # 输出报告
```

---

## 🔒 隐私与安全

| 项目 | 处理方式 |
|------|---------|
| Twitter Cookie | 环境变量 `TWITTER_AUTH_TOKEN` / `TWITTER_CT0` |
| API Key | 环境变量 `FRONTRUN_API_KEY` |
| 本地数据 | `.gitignore` 排除，不上传 |
| 历史记录 | 本地存储，不上传云端 |

✅ **所有敏感信息均通过环境变量传入，不硬编码在代码中**

---

## 🐛 常见问题

### Q: Twitter 认证失败？
**A**:
- 检查 `TWITTER_AUTH_TOKEN` 和 `TWITTER_CT0` 是否正确
- Token 可能过期，需要重新从浏览器获取
- 确保账号未被限制

### Q: 没有找到项目？
**A**:
- 检查 KOL 列表是否配置正确
- 检查 Twitter 请求是否正常工作

### Q: 报告中的项目太多/太少？
**A**:
- 调整 `min_kol_count` 阈值（默认 3）
- 添加更多项目到 `excluded_projects`
- 调整 KOL 监控列表

### Q: 如何添加新的 KOL？
**A**: 编辑 `config.yaml`：
```yaml
tweet_watchlist:
  - new_kol_username

following_watchlist:
  - new_kol_username
```

---

## 🤝 贡献指南

欢迎提交 Issue 和 PR！

1. **Fork** 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 创建 **Pull Request**

---

## 📜 许可证

[MIT License](LICENSE) - 自由使用、修改和分发

---

## 🙏 致谢

- [Frontrun.pro](https://frontrun.pro) - KOL 关注数据
- [twitter-cli](https://github.com/public-clis/twitter-cli) - Twitter 工具
- [OpenClaw](https://openclaw.ai) - Agent 平台

---

## 📮 联系作者

- **Twitter**: [@yn_btc](https://x.com/yn_btc)
- **GitHub**: [@ynbtc](https://github.com/ynbtc)

如果这个项目帮到了你，给个 ⭐ 让更多人发现它！

---

<p align="center">
  <sub>Built with ❤️ by yn_btc</sub>
</p>