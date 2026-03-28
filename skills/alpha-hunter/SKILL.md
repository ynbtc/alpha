---
name: alpha-hunter
description: 自动追踪 Twitter KOL 的推文和关注列表，挖掘早期 Alpha 项目。监控指定博主每日推文，追踪 KOL 关注动态，通过 Frontrun.pro API 验证项目关注度，输出汇总报告。
author: OpenClaw Community
version: 1.0.0
homepage: https://github.com/openclaw/alpha-hunter
license: MIT
tags:
  - twitter
  - alpha
  - crypto
  - kol
  - monitoring
  - research
requires:
  bins: [twitter, curl, jq]
  skills: [twitter-cli]
env:
  - TWITTER_AUTH_TOKEN
  - TWITTER_CT0
  - FRONTRUN_API_KEY
  - TELEGRAM_BOT_TOKEN
  - TELEGRAM_CHAT_ID
---

# Alpha Hunter - 早期项目挖掘助手

自动追踪 Twitter KOL，挖掘早期 Alpha 项目的智能工具。

## 核心功能

### 1. 推文监控
扫描指定博主的每日推文，提取早期项目信息：
- 新项目提及
- 合约地址检测
- 关键词匹配（launch, alpha, gem, 等）

### 2. 关注列表追踪
监控 KOL 的关注动态，发现新增项目：
- 每日对比关注列表
- 识别新增关注项目
- 记录关注时间

### 3. Frontrun.pro 验证
通过 API 验证项目 KOL 关注度：
- KOL 关注数 >= 3：记录为高潜力项目
- KOL 关注数 < 3：过滤掉

### 4. 智能汇总
输出格式化的 Alpha 项目报告（中文）

## 安装

### 1. 安装依赖

```bash
# 确保已安装 twitter-cli
which twitter || pip install twitter-cli

# 确保已安装 jq
which jq || apt install jq
```

### 2. 配置环境变量

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

### 3. 配置监控列表

编辑 `config.yaml`：

```yaml
# 推文监控博主
tweet_watchlist:
  - leakmealpha
  - BR4ted
  - GuarEmperor
  # ... 添加更多

# 关注列表监控
following_watchlist:
  - _GuarEmperor
  - 0xtiao
  # ... 添加更多

# Frontrun.pro API
frontrun:
  min_kol_count: 3

# 排除列表（KOL/老项目）
excluded_projects:
  - Cointelegraph
  - Pumpfun
  # ... 添加更多
```

## 使用方法

### 手动运行

```bash
# 一键运行全部
alpha-hunter run-all

# 单独功能
alpha-hunter scan-tweets       # 扫描推文
alpha-hunter check-following   # 检查关注列表
alpha-hunter verify-candidates # 验证候选项目
alpha-hunter report            # 生成报告
```

### 自动定时运行

```bash
# 添加到 cron（每天 8:00 和 20:00）
0 8,20 * * * /path/to/alpha-hunter run-all
```

## 输出格式

### 中文报告模板

```
📊 今日热门项目 (YYYY-MM-DD)
共X个新项目

1、项目名称：XXX
项目推特：https://x.com/XXX
项目介绍：中文简介
KOL关注数：X⭐

...

---
📈 候选X个 | 新增X个
```

## 隐私保护

- 所有敏感信息（Twitter Cookie、API Key）通过环境变量传入
- 不硬编码任何个人凭证
- 历史记录文件本地存储

## 自定义配置

### 添加新的 KOL 到监控列表

编辑脚本中的 `KOL_ACCOUNTS` 数组

### 添加新的排除项目

编辑脚本中的 `EXCLUDED_PROJECTS` 数组

### 修改 KOL 关注阈值

编辑 `config.yaml` 中的 `min_kol_count`

## License

MIT
