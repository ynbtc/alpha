#!/bin/bash
# Alpha Hunter 安装脚本

set -e

echo "🚀 安装 Alpha Hunter..."

# 检查依赖
echo "📦 检查依赖..."

if ! command -v twitter &> /dev/null; then
    echo "❌ twitter-cli 未安装"
    echo "请运行: pip install twitter-cli"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq 未安装"
    echo "请运行: apt install jq (Linux) 或 brew install jq (Mac)"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl 未安装"
    exit 1
fi

echo "✅ 依赖检查通过"

# 创建目录
echo "📁 创建目录结构..."
mkdir -p data/{tweets,following,projects} reports logs

# 复制配置模板
if [ ! -f "config.yaml" ]; then
    echo "📝 创建配置文件..."
    cp config.yaml.template config.yaml
    echo "⚠️  请编辑 config.yaml 配置你的监控列表"
fi

# 检查环境变量
echo "🔐 检查环境变量..."
if [ -z "$TWITTER_AUTH_TOKEN" ] || [ -z "$TWITTER_CT0" ]; then
    echo "⚠️  警告: TWITTER_AUTH_TOKEN 和 TWITTER_CT0 未设置"
    echo "请运行:"
    echo "  export TWITTER_AUTH_TOKEN='your_token'"
    echo "  export TWITTER_CT0='your_ct0'"
fi

if [ -z "$FRONTRUN_API_KEY" ]; then
    echo "⚠️  警告: FRONTRUN_API_KEY 未设置"
    echo "请运行: export FRONTRUN_API_KEY='your_api_key'"
fi

# 创建快捷方式
echo "🔗 创建快捷方式..."
chmod +x alpha-hunter.sh
ln -sf "$(pwd)/alpha-hunter.sh" /usr/local/bin/alpha-hunter 2>/dev/null || true

echo ""
echo "✅ 安装完成!"
echo ""
echo "使用方法:"
echo "  alpha-hunter run-all    # 一键运行"
echo "  alpha-hunter --help     # 查看帮助"
echo ""
echo "配置文件: $(pwd)/config.yaml"
echo "报告目录: $(pwd)/reports/"
