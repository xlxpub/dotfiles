#!/usr/bin/env bash
#
# update_player_team.sh
# 功能：根据 program/list 接口返回的数据，批量调用 player/modify 接口，
#       将每个 player_id 的 team_id 更新为其所属的 a_team_id。
#
# 用法：
#   ./update_player_team.sh [pid]                # 正式执行
#   DEBUG=1 ./update_player_team.sh [pid]        # 调试模式：只打印 payload，不调用修改接口
#
# 依赖：bash 4+, curl, jq
# ---------------------------------------------------------------------------

# Bash 严格模式：
#   -e          任一命令失败立即退出
#   -u          使用未定义变量时报错
#   -o pipefail 管道中任一段失败即视为整条失败
set -euo pipefail

# ===== 全局配置 ============================================================

# 调试模式开关，默认关闭。${VAR:-默认值} 表示变量未设置时使用默认值
readonly DEBUG="${DEBUG:-0}"

# 第一个命令行参数作为 pid，未传时使用默认值
readonly PID="${1:-ETTUCL_25_26_5022258}"

# 比赛 id（与 pid 同前缀）
readonly MATCH_ID="ETTUCL_25_26"

# 接口域名前缀，统一管理便于后续切换环境
readonly API_HOST="http://cms.video.cloud.cctv.com"

# 通用 Cookie，从环境变量 CMS_COOKIE 读取（敏感信息不写在脚本里）
# 使用方式：
#   export CMS_COOKIE='access_token=xxx; sign=xxx; ...'
#   ./update_player_team.sh
# ${VAR:?msg} 表示变量未设置或为空时报错并退出
readonly COOKIE="${CMS_COOKIE:?请先设置环境变量 CMS_COOKIE，例如 export CMS_COOKIE='access_token=xxx; ...'}"

# 浏览器 UA，模拟真实请求
readonly USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'

# ===== 工具函数 ============================================================

# 简易日志函数：log INFO/WARN/ERROR/DEBUG "消息"
log() {
  local level="$1"; shift
  # printf 比 echo 更安全（不会因 -e/-n 等参数被吞掉）
  printf '[%s] %s\n' "$level" "$*"
}

# 前置依赖检查：保证 curl/jq 已安装
require_cmd() {
  for cmd in "$@"; do
    # command -v 用于判断命令是否存在，比 which 更可移植
    command -v "$cmd" >/dev/null 2>&1 || {
      log ERROR "缺少依赖命令：$cmd，请先安装"
      exit 1
    }
  done
}

# ===== 业务函数 ============================================================

# 拉取节目（运动员）列表，返回原始 JSON
fetch_program_list() {
  # URL 中的查询参数较多，统一拼接成变量更清晰
  local url="${API_HOST}/api/sports/program/list"
  url+="?env=PROD&classification_type=event&page=1&page_size=20"
  url+="&match_id=${MATCH_ID}&parent_id=${PID}&level=2"
  url+="&keyword=&play_time=&program_status=&status=&epg_source=&site_status="

  # -s 静默；-f 在 HTTP 错误时返回非 0；--insecure 跳过证书校验（按需）
  curl -sf --insecure \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: zh,zh-CN;q=0.9' \
    -H 'Cache-Control: no-cache' \
    -H 'Connection: keep-alive' \
    -H 'Pragma: no-cache' \
    -H "User-Agent: ${USER_AGENT}" \
    -b "$COOKIE" \
    "$url"
}

# 从 JSON 中解析 a_team_id 与 player_id，输出每行 "team_id<TAB>player_id"
parse_pairs() {
  local json="$1"
  # jq 表达式：
  #   .data.list[]              遍历列表
  #   .a_team_id as $tid        暂存 a_team_id 到变量 $tid
  #   .a_players[]?             安全遍历 a_players（缺失/空时不报错）
  #   "\($tid)\t\(.player_id)"  字符串插值，输出 team_id<TAB>player_id
  printf '%s' "$json" | jq -r '
    .data.list[]
    | .a_team_id as $tid
    | .a_players[]?
    | "\($tid)\t\(.player_id)"
  '
}

# 调用修改接口，将指定 player 绑定到指定 team
modify_player_team() {
  local player_id="$1"
  local team_id="$2"
  # 构造 JSON body，使用 jq 生成可保证转义安全（即使 id 中有特殊字符）
  local payload
  payload=$(jq -n \
    --arg id "$player_id" \
    --arg team_id "$team_id" \
    '{id:$id, team_id:$team_id}')

  curl -sf --insecure \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: zh,zh-CN;q=0.9' \
    -H 'Cache-Control: no-cache' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -H 'Origin: http://cms.video.cloud.cctv.com' \
    -H 'Pragma: no-cache' \
    -H "Referer: ${API_HOST}/event/match/athlete/${MATCH_ID}" \
    -H "User-Agent: ${USER_AGENT}" \
    -b "$COOKIE" \
    --data-raw "$payload" \
    "${API_HOST}/api/sports/player/modify?env=PROD&classification_type=event"
}

# ===== 主流程 ==============================================================

main() {
  # 1. 检查依赖
  require_cmd curl jq

  log INFO "开始处理 pid=${PID} (DEBUG=${DEBUG})"

  # 2. 拉取列表
  local resp
  resp=$(fetch_program_list) || {
    log ERROR "拉取 program/list 失败"
    exit 1
  }

  # 3. 解析 (team_id, player_id) 列表
  local pairs
  pairs=$(parse_pairs "$resp")

  # 空数据保护：避免 while 循环空跑
  if [[ -z "$pairs" ]]; then
    log WARN "未获取到任何 player，请检查 pid 或 cookie"
    exit 1
  fi

  log INFO "待更新列表："
  printf '%s\n' "$pairs"
  printf -- '-----------------------------\n'

  # 4. 调试模式提示
  if [[ "$DEBUG" == "1" ]]; then
    log DEBUG "调试模式已开启：只打印 payload，不实际调用修改接口"
  fi

  # 5. 逐行处理：IFS=$'\t' 表示按 Tab 切分；read -r 防止反斜杠转义
  local team_id player_id ok=0 fail=0
  while IFS=$'\t' read -r team_id player_id; do
    # 跳过空行（防御性）
    [[ -z "$player_id" ]] && continue

    log INFO ">>> player_id=${player_id} => team_id=${team_id}"

    if [[ "$DEBUG" == "1" ]]; then
      # 调试模式只打印不发请求
      log DEBUG "    payload: {\"id\":\"${player_id}\",\"team_id\":\"${team_id}\"}"
      continue
    fi

    # 调用修改接口；失败时计数但继续（不让 set -e 终止脚本）
    if modify_player_team "$player_id" "$team_id"; then
      printf '\n'
      ok=$((ok + 1))
    else
      log ERROR "修改失败：player_id=${player_id}"
      fail=$((fail + 1))
    fi
  done <<< "$pairs"

  # 6. 汇总
  log INFO "全部完成：成功=${ok} 失败=${fail}"
}

# 仅在脚本被直接执行时调用 main（被 source 时不执行）
# "${BASH_SOURCE[0]}" 是当前文件路径，"$0" 是入口脚本路径，二者相同代表直接执行
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
