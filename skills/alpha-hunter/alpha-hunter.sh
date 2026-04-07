#!/bin/bash
# Alpha Hunter - 早期项目挖掘助手
# 自动追踪 KOL 推文和关注列表，挖掘 Alpha 项目

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.yaml"
DATA_DIR="${SCRIPT_DIR}/data"
REPORTS_DIR="${SCRIPT_DIR}/reports"
LOGS_DIR="${SCRIPT_DIR}/logs"

# Telegram 配置（从环境变量读取）
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

# Twitter 认证（从环境变量读取）
export TWITTER_AUTH_TOKEN="${TWITTER_AUTH_TOKEN:-}"
export TWITTER_CT0="${TWITTER_CT0:-}"

# 创建目录
mkdir -p "${DATA_DIR}"/{tweets,following,projects} "${REPORTS_DIR}" "${LOGS_DIR}"

# 日志函数（提前定义）
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOGS_DIR}/alpha-hunter.log"
}

# 检查必需的环境变量
if [ -z "$TWITTER_AUTH_TOKEN" ] || [ -z "$TWITTER_CT0" ]; then
    log "❌ 错误: 请设置 TWITTER_AUTH_TOKEN 和 TWITTER_CT0 环境变量"
    log "示例: export TWITTER_AUTH_TOKEN='your_token'"
    exit 1
fi

# KOL 账号列表（用于过滤，这些不是项目）
KOL_ACCOUNTS=(
    # 推文监控博主（14位）
    "leakmealpha" "BR4ted" "GuarEmperor" "0xvietnguyen" "Trappwurld"
    "tenacious_ar" "0xRohitz" "nics_off" "Alfa_or_Not" "0xdetweiler"
    "zacxbt" "getmoni_io" "spice0182" "huseyin1tekin"
    # 关注列表监控（10位）
    "_GuarEmperor" "0xtiao" "kaisi420" "eternaldegen"
    "Crypto_Goatinho" "0xminion" "scriptdotmoney" "sanyi_eth_"
    # 知名大V
    "vitalikbuterin" "elonmusk" "cz_binance"
    # 其他常见KOL（从搜索结果中发现的）
    "yn_btc" "WY_mask" "bashorunedward" "parlettodotbet"
    "CryptoLakhan" "alex_atoms" "bitclawai" "BigDott_Sidra"
    "HottieBabeGem" "asedd72" "weingfo" "ssheyii"
)

# 推文监控列表（从这些博主的推文中提取项目）
TWEET_WATCHLIST=(
    "leakmealpha" "BR4ted" "GuarEmperor" "0xvietnguyen" "Trappwurld"
    "tenacious_ar" "0xRohitz" "nics_off" "Alfa_or_Not" "0xdetweiler"
    "zacxbt" "getmoni_io" "spice0182" "huseyin1tekin"
)

# 关注列表监控（监控这些 KOL 新关注了谁）
FOLLOWING_WATCHLIST=(
    "feibo03" "0xtiao" "_GuarEmperor" "kaisi420" "sanyi_eth_"
    "eternaldegen" "0xdetweiler" "yuyue_chris" "banditxbt" "Eli5defi"
    "Cady_btc" "BR4ted" "moo9000" "lmrankhan" "0xminion"
    "Toro_Ceo" "probablytails" "0xLuo" "ETH3210" "jiumeng88888"
    "Crypto_Goatinho" "roybitsir" "zacxbt" "cz_binance" "wsdxbz1"
    "AlphaSeeker21" "heyibinance" "0xSunNFT" "ShockedJS" "HunterOnlyETH"
    "DUANMEI11" "sunyuchentron" "0xmagnolia" "miguelrare" "scriptdotmoney"
    "BitCloutCat" "CryptoDevinL" "notab2d_"
)

# 已发币/成名已久的老项目（排除列表）
EXCLUDED_PROJECTS=(
    # 知名媒体/平台
    "Cointelegraph" "CoinDesk" "TheBlock__" "decryptmedia" "CryptoSlate"
    # 已发币大项目/平台
    "Pumpfun" "pumpspotlight" "solana" "SolanaSensei" "solana_devs"
    "ethereum" "bitcoin" "binance" "coinbase" "krakenfx" "OKX"
    "cookiedotfun" "cookie3_com" "CookieDAO"
    # 知名DeFi协议
    "Uniswap" "aave" "compoundfinance" "CurveFinance" "Balancer" 
    "1inch" "dydx" "GMX_IO" "SushiSwap" "PancakeSwap"
    # 知名NFT/游戏
    "opensea" "blur_io" "MagicEden" "AxieInfinity" "stepn"
    # 知名L2/基础设施
    "arbitrum" "optimismFND" "Base" "Starknet" "zksync"
    # 其他知名项目
    "Polymarket" "KalshiTrade" "CarOnPolymarket"
    "Chainlink" "TheGraph" "graphprotocol"
    "lensprotocol" "farcaster_xyz"
)



# 检查是否为 KOL 账号（不是项目）
is_kol_account() {
    local username="$1"
    for kol in "${KOL_ACCOUNTS[@]}"; do
        if [ "$username" = "$kol" ]; then
            return 0
        fi
    done
    return 1
}

# 检查是否为已发币/老项目（排除）
is_excluded_project() {
    local username="$1"
    for excluded in "${EXCLUDED_PROJECTS[@]}"; do
        if [ "$username" = "$excluded" ]; then
            return 0
        fi
    done
    return 1
}

# Telegram 推送函数
send_telegram() {
    local message="$1"
    local report_file="$2"
    
    if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
        log "⚠️  Telegram Bot Token 未配置，跳过推送"
        return 1
    fi
    
    # 发送文本消息
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\",\"parse_mode\":\"Markdown\",\"disable_web_page_preview\":true}" > /dev/null
    
    # 如果有报告文件，也发送文件
    if [ -n "$report_file" ] && [ -f "$report_file" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" \
            -F "chat_id=${TELEGRAM_CHAT_ID}" \
            -F "document=@${report_file}" \
            -F "caption=Alpha Hunter 详细报告" > /dev/null
    fi
    
    log "✅ Telegram 推送完成"
}

# 检查依赖
check_deps() {
    local missing=()
    
    if ! command -v twitter &> /dev/null; then
        missing+=("twitter-cli")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "❌ 缺少依赖: ${missing[*]}"
        exit 1
    fi
    
    log "✅ 依赖检查通过"
}

# 扫描推文（从监控博主推文中提取项目提及）
scan_tweets() {
    log "🔍 开始扫描推文..."
    
    local date_str=$(date +%Y%m%d)
    local candidates_file="${DATA_DIR}/projects/daily_candidates_${date_str}.txt"
    local sources_file="${DATA_DIR}/projects/tweet_sources_${date_str}.txt"
    
    # 清空旧数据
    > "$candidates_file"
    > "$sources_file"
    
    local found_projects=()
    
    for username in "${TWEET_WATCHLIST[@]}"; do
        log "  获取 @$username 的推文..."
        
        local tweets
        if tweets=$(twitter tweets "$username" --max 20 --json 2>/dev/null); then
            
            # ===== 1. 从推文文本中提取 @提及 =====
            local mentions
            mentions=$(echo "$tweets" | jq -r '.data[].text // .[] .text // empty' 2>/dev/null | grep -oE '@[a-zA-Z0-9_]+' | sort -u)
            
            for mention in $mentions; do
                local clean_name="${mention#@}"
                if [[ ${#clean_name} -gt 3 ]] && ! is_kol_account "$clean_name" && ! is_excluded_project "$clean_name"; then
                    found_projects+=("$clean_name")
                    echo "$clean_name|$username" >> "$sources_file"
                    log "  @$username 的推文中发现项目: @$clean_name"
                fi
            done
            
            # ===== 2. 提取引用推文作者 =====
            local quoted_authors
            quoted_authors=$(echo "$tweets" | jq -r '.data[] | select(.quotedTweet) | .quotedTweet.author.screenName // empty' 2>/dev/null | sort -u)
            
            for author in $quoted_authors; do
                if [[ ${#author} -gt 3 ]] && ! is_kol_account "$author" && ! is_excluded_project "$author"; then
                    found_projects+=("$author")
                    echo "$author|$username" >> "$sources_file"
                    log "  @$username 的引用推文中发现项目: @$author"
                fi
            done
            
            # ===== 3. 提取转发原作者 =====
            local retweet_authors
            retweet_authors=$(echo "$tweets" | jq -r '.data[] | select(.retweetedBy) | .retweetedBy.screenName // empty' 2>/dev/null | sort -u)
            
            for author in $retweet_authors; do
                if [[ ${#author} -gt 3 ]] && ! is_kol_account "$author" && ! is_excluded_project "$author"; then
                    found_projects+=("$author")
                    echo "$author|$username" >> "$sources_file"
                fi
            done
            
        else
            log "  ⚠️  无法获取 @$username 的推文"
        fi
        
        # 避免请求过快
        sleep 2
    done
    
    # 去重并保存发现的项目
    printf '%s\n' "${found_projects[@]}" | sort -u | grep -v '^$' > "$candidates_file"
    
    local count
    count=$(wc -l < "$candidates_file" 2>/dev/null || echo 0)
    log "✅ 推文扫描完成，发现 $count 个候选项目"
    
    # 显示前10个发现的项目
    if [ "$count" -gt 0 ]; then
        log "  前10个项目:"
        head -10 "$candidates_file" | while read -r proj; do
            log "    - $proj"
        done
    fi
}

# 检查关注列表
check_following() {
    log "👥 开始检查关注列表..."
    
    local date_str=$(date +%Y%m%d)
    local following_dir="${DATA_DIR}/following"
    local sources_file="${DATA_DIR}/projects/following_sources_${date_str}.txt"
    
    # 清空旧数据
    > "$sources_file"
    
    for target in "${FOLLOWING_WATCHLIST[@]}"; do
        log "  检查 @$target 的关注列表..."
        
        local current_file="${following_dir}/${target}_${date_str}.json"
        local prev_file="${following_dir}/${target}_latest.json"
        
        # 获取当前关注列表
        if twitter following "$target" --max 100 --json > "$current_file" 2>/dev/null; then
            
            # 如果有历史数据，对比找出新增关注
            if [ -f "$prev_file" ]; then
                local new_follows
                new_follows=$(comm -13 \
                    <(jq -r '.[] | .username // .screen_name // .screenName // empty' "$prev_file" 2>/dev/null | sort) \
                    <(jq -r '.[] | .username // .screen_name // .screenName // empty' "$current_file" 2>/dev/null | sort) \
                    | head -20)
                
                if [ -n "$new_follows" ]; then
                    log "  🆕 @$target 新增关注:"
                    echo "$new_follows" | while read -r user; do
                        # 过滤 KOL 账号
                        if ! is_kol_account "$user"; then
                            log "    - @$user"
                            echo "$user" >> "${DATA_DIR}/projects/following_candidates_${date_str}.txt"
                            echo "$user|$target" >> "$sources_file"
                        fi
                    done
                fi
            fi
            
            # 更新最新快照
            cp "$current_file" "$prev_file"
        else
            log "  ⚠️  无法获取 @$target 的关注列表"
        fi
        
        sleep 2
    done
    
    log "✅ 关注列表检查完成"
}

# 验证项目 KOL 关注度
verify_project() {
    local username="$1"
    local api_key="${FRONTRUN_API_KEY:-}"
    
    if [ -z "$api_key" ]; then
        log "❌ 错误: 请设置 FRONTRUN_API_KEY 环境变量"
        return 1
    fi
    
    if [ -z "$username" ]; then
        log "❌ 请提供 Twitter 用户名"
        return 1
    fi
    
    # 清理用户名
    username="${username#@}"
    
    log "  🔎 验证 @$username 的 KOL 关注度..."
    
    local response
    response=$(curl -s -X GET \
        "https://api.frontrun.pro/api/v1/pro/twitter/${username}/smart-followers/count" \
        -H "accept: application/json" \
        -H "X-Copilot-Client-Language: ZH_CN" \
        -H "X-Copilot-Client-Platform: CHROME_EXTENSION" \
        -H "X-Copilot-Client-Version: 1.0.0" \
        -H "Authorization: Bearer ${api_key}" 2>/dev/null)
    
    if [ -z "$response" ]; then
        log "  ⚠️  API 无响应"
        echo "0"
        return 1
    fi
    
    local count
    count=$(echo "$response" | jq -r '.data.totalCount // .data.count // .count // 0' 2>/dev/null)
    
    if [ -z "$count" ] || [ "$count" = "null" ]; then
        count=0
    fi
    
    echo "$count"
}

# 获取项目介绍（Twitter Bio）
get_project_bio() {
    local username="$1"
    
    if [ -z "$username" ]; then
        echo "暂无介绍"
        return
    fi
    
    # 清理用户名
    username="${username#@}"
    
    # 获取用户资料
    local user_info
    user_info=$(twitter user "$username" --json 2>/dev/null)
    
    if [ -n "$user_info" ]; then
        local bio
        bio=$(echo "$user_info" | jq -r '.data.bio // .data.description // empty' 2>/dev/null | head -c 200)
        if [ -n "$bio" ] && [ "$bio" != "null" ]; then
            echo "$bio"
        else
            echo "暂无介绍"
        fi
    else
        echo "暂无介绍"
    fi
}

# 批量验证候选项目
verify_candidates() {
    log "🎯 开始验证候选项目..."
    
    local date_str=$(date +%Y%m%d)
    local candidates_file="${DATA_DIR}/projects/daily_candidates_${date_str}.txt"
    local following_candidates="${DATA_DIR}/projects/following_candidates_${date_str}.txt"
    local verified_file="${DATA_DIR}/projects/verified_${date_str}.json"
    
    # 合并所有候选
    local all_candidates="${DATA_DIR}/projects/all_candidates_${date_str}.txt"
    cat "$candidates_file" "$following_candidates" 2>/dev/null | sort -u > "$all_candidates"
    
    local total=$(wc -l < "$all_candidates")
    log "  共 $total 个候选项目需要验证"
    
    # 初始化验证结果文件
    echo "[]" > "$verified_file"
    
    local idx=0
    while IFS= read -r username; do
        idx=$((idx + 1))
        
        # 跳过空行
        [ -z "$username" ] && continue
        
        log "  [$idx/$total] 验证 @$username..."
        
        local kol_count
        kol_count=$(verify_project "$username")
        
        # 添加到结果
        local entry
        entry=$(jq -n \
            --arg username "$username" \
            --argjson count "$kol_count" \
            --arg date "$(date -Iseconds)" \
            '{username: $username, kol_count: $count, verified_at: $date}')
        
        jq ". += [$entry]" "$verified_file" > "${verified_file}.tmp" && mv "${verified_file}.tmp" "$verified_file"
        
        # API 限速保护
        sleep 1
    done < "$all_candidates"
    
    log "✅ 验证完成，结果保存至 $verified_file"
}

# 获取项目来源
get_project_source() {
    local username="$1"
    local date_str="$2"
    local tweet_sources="${DATA_DIR}/projects/tweet_sources_${date_str}.txt"
    local following_sources="${DATA_DIR}/projects/following_sources_${date_str}.txt"
    local sources=""
    
    # 检查推文来源
    if [ -f "$tweet_sources" ]; then
        local tweet_kol
        tweet_kol=$(grep -F "${username}|" "$tweet_sources" 2>/dev/null | head -1 | cut -d'|' -f2)
        if [ -n "$tweet_kol" ]; then
            sources="[推文提及] @${tweet_kol}"
        fi
    fi
    
    # 检查关注来源
    if [ -f "$following_sources" ]; then
        local following_kol
        following_kol=$(grep -F "${username}|" "$following_sources" 2>/dev/null | head -1 | cut -d'|' -f2)
        if [ -n "$following_kol" ]; then
            if [ -n "$sources" ]; then
                sources="${sources} | [新增关注] @${following_kol}"
            else
                sources="[新增关注] @${following_kol}"
            fi
        fi
    fi
    
    if [ -z "$sources" ]; then
        sources="[未知来源]"
    fi
    
    echo "$sources"
}

# 生成报告
generate_report() {
    log "📝 生成报告..."
    
    local date_str=$(date +%Y%m%d)
    local date_display=$(date +%Y-%m-%d)
    local report_file="${REPORTS_DIR}/alpha-report-${date_display}.md"
    local verified_file="${DATA_DIR}/projects/verified_${date_str}.json"
    
    # 筛选所有 KOL >= 3 的项目（不过滤KOL账号，因为候选阶段已过滤）
    local all_projects
    all_projects=$(jq '[.[] | select(.kol_count >= 3)] | sort_by(.kol_count) | reverse' "$verified_file" 2>/dev/null)
    
    local project_count
    project_count=$(echo "$all_projects" | jq 'length')
    
    # 生成 Markdown 报告（使用指定模板）
    cat > "$report_file" << EOF
📊 今日热门项目 (${date_display}) - 共${project_count}个项目

EOF

    if [ "$project_count" -eq 0 ]; then
        echo "今日未发现项目" >> "$report_file"
    else
        local idx=0
        echo "$all_projects" | jq -r '.[] | "\(.username)|\(.kol_count)"' | while IFS='|' read -r username kol_count; do
            idx=$((idx + 1))
            # 获取项目介绍
            local bio
            bio=$(get_project_bio "$username")
            # 获取项目来源
            local source
            source=$(get_project_source "$username" "$date_str")
            cat >> "$report_file" << EOF
${idx}、项目名称：${username}
项目推特：https://x.com/${username}
项目介绍：${bio}
KOL关注数：${kol_count} ⭐
来源：${source}

EOF
            # API 限速
            sleep 1
        done
    fi
    
    # 添加统计数据
    local total_candidates=$(wc -l < "${DATA_DIR}/projects/all_candidates_${date_str}.txt" 2>/dev/null || echo 0)
    
    cat >> "$report_file" << EOF
---
📈 候选项目: ${total_candidates} 个 | ✅ KOL>=3: ${project_count} 个

*Generated by Alpha Hunter v0.1.0*
EOF

    log "✅ 报告已生成: $report_file"
    
    # 生成 Telegram 推送消息（使用指定模板）
    local tg_message="📊 今日热门项目 (${date_display}) - 共${project_count}个项目\n"

    if [ "$project_count" -eq 0 ]; then
        tg_message+="\n今日未发现项目\n"
    else
        local idx=0
        echo "$all_projects" | jq -r '.[] | "\(.username)|\(.kol_count)"' | head -15 | while IFS='|' read -r username kol_count; do
            idx=$((idx + 1))
            # 获取项目介绍
            local bio
            bio=$(get_project_bio "$username")
            # 获取项目来源
            local source
            source=$(get_project_source "$username" "$date_str")
            tg_message+="\n${idx}、${username}\n"
            tg_message+="https://x.com/${username}\n"
            tg_message+="${bio:0:80}... (${kol_count}⭐)\n"
            tg_message+="来源：${source}\n"
            # API 限速
            sleep 1
        done
    fi

    tg_message+="\n---\n"
    tg_message+="📈 候选: ${total_candidates}个 | KOL>=3: ${project_count}个"
    
    # 发送 Telegram 推送
    send_telegram "$tg_message" "$report_file"
    
    # 输出报告内容
    cat "$report_file"
}

# 一键运行全部
run_all() {
    log "🚀 Alpha Hunter 开始运行..."
    
    check_deps
    scan_tweets
    check_following
    verify_candidates
    generate_report
    
    log "✅ 全部任务完成！"
}

# 主命令处理
case "${1:-run-all}" in
    scan-tweets)
        check_deps
        scan_tweets
        ;;
    check-following)
        check_deps
        check_following
        ;;
    verify-project)
        check_deps
        count=$(verify_project "$2")
        echo "项目 @$2 的 KOL 关注数: $count"
        ;;
    verify-candidates)
        check_deps
        verify_candidates
        ;;
    report)
        generate_report
        ;;
    run-all)
        run_all
        ;;
    *)
        echo "用法: alpha-hunter [command]"
        echo ""
        echo "Commands:"
        echo "  scan-tweets       扫描推文"
        echo "  check-following   检查关注列表"
        echo "  verify-project    验证单个项目"
        echo "  verify-candidates 批量验证候选项目"
        echo "  report            生成报告"
        echo "  run-all           一键运行全部"
        echo ""
        exit 1
        ;;
esac
