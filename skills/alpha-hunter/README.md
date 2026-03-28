# Alpha Hunter

自动追踪 Twitter KOL，挖掘早期 Alpha 项目的智能工具。

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/openclaw/alpha-hunter.git
cd alpha-hunter
```

### 2. 安装依赖

```bash
# 安装 twitter-cli
pip install twitter-cli

# 安装 jq (Linux)
apt install jq

# 或 Mac
brew install jq
```

### 3. 配置环境变量

```bash
# Twitter 认证（必需）
export TWITTER_AUTH_TOKEN="your_auth_token_here"
export TWITTER_CT0="your_ct0_here"

# Frontrun.pro API（必需）
export FRONTRUN_API_KEY="your_api_key_here"

# Telegram 推送（可选）
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
```

> 💡 如何获取 Twitter Cookie:
> 1. 登录 x.com
> 2. 打开浏览器开发者工具 (F12)
> 3. 找到 Application/Storage > Cookies
> 4. 复制 `auth_token` 和 `ct0` 的值

### 4. 运行

```bash
./alpha-hunter.sh run-all
```

## 自定义配置

复制配置模板并修改：

```bash
cp config.yaml.template config.yaml
# 编辑 config.yaml 添加你想监控的 KOL
```

## 定时运行

```bash
# 每天 8:00 和 20:00 运行
0 8,20 * * * /path/to/alpha-hunter/alpha-hunter.sh run-all >> /var/log/alpha-hunter.log 2>&1
```

## 隐私保护

- ✅ 所有敏感信息通过环境变量传入
- ✅ 不硬编码任何个人凭证
- ✅ 历史记录本地存储

## 输出

报告保存在 `reports/` 目录，格式：

```
📊 今日热门项目 (YYYY-MM-DD)
共X个新项目

1、项目名称：XXX
项目推特：https://x.com/XXX
项目介绍：中文简介
KOL关注数：X⭐
```

## License

MIT
