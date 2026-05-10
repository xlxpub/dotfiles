#!/usr/bin/env zsh

set -euo pipefail

# 捕获错误命令并打印详细信息
trap 'echo "Error: $0: line $LINENO"; echo "Failed command: ${ZSH_COMMAND:-<unknown>}"; echo "Exit code: $?"' ERR

DEBUG=${DEBUG:-false}
export http_proxy="http://127.0.0.1:8888"

get_program_list() {
  # 命名参数：--match_id (必填), --page_size, --parent_id, --level
  local match_id="" page_size=50 parent_id="" level=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      --match_id)  match_id=$2;   shift 2 ;;
      --page_size) page_size=$2;  shift 2 ;;
      --parent_id) parent_id=$2;  shift 2 ;;
      --level)     level=$2;      shift 2 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  [[ -z "$match_id" ]] && { echo "Error: --match_id is required" >&2; return 1; }
  CMS_COOKIE=${CMS_COOKIE:?"CMS_COOKIE is required"}

  [[ "$DEBUG" == "true" ]] && {
    printf 'match_id=%s,page_size=%s,parent_id=%s;\n' "$match_id" "$page_size" "$parent_id"
    return 0
  }
  # return 0

  programs=$( curl -sf "http://cms.video.cloud.cctv.com/api/sports/program/list?match_id=${match_id}&env=PROD&classification_type=event&category=sports&page=1&page_size=${page_size}&level=${level}&keyword=&pid=&play_time=&team_id=&program_status=&status=&parent_id=${parent_id}" \
  -H 'Accept: application/json, text/plain, */*' \
  -b "$CMS_COOKIE" \
  --insecure)

code=$(echo $programs| jq -r '.code')
if [ $code -ne 0 ]; then
  msg=$(echo $programs| jq -r '.msg')
  echo "get_program_list failed: code:$code,msg: $msg"
  return 1
fi

echo $programs
}

programs=$(get_program_list --match_id ETTUCL_25_26 --page_size 10 --level 1)

#echo "programs: $programs"

epgids=$(echo $programs| jq -r '.data.list[]|.epg_id')
printf "level 1 prorams:%s\n\n" "$epgids"

i=0
for epgid in $epgids; do
  echo "epgid: $epgid"
  subprograms=$(get_program_list --match_id ETTUCL_25_26 --page_size 30 --parent_id $epgid --level 2)
  printf "level 2 prorams:%s\n\n" $(echo $subprograms| jq -r '.data.list|map(.epg_id)|join(",")')
  ((i++))
  [[ "$i" -eq 3 ]] && break
done
