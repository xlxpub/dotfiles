#!/usr/bin/env bash
;

set -euo pipefail


cat season_match.json|jq '.[0].results |map(select(.status_id==0))|length'
# 找到二级赛程 tournament_id 看看是否都是一个
subids=$(cat season_match.json|jq '.[0].results |map(select(.status_id>0))|map(select(.match_ids|length>0))|map(.match_ids)|add|.[]')
# echo $subids"------"
tournaments=$(cat season_match.json|jq --arg ids "$subids" \
  '($ids|split("\n")|map(tonumber) )as $ids
  |.[0].results 
  |map(select(.status_id>0 and (.id|IN($ids[])) ))
  |map(.tournament_id)
  |sort
  |unique
  ')
  #'($ids|split("\n")|map(tonumber) )as $ids|.[0].results |map(select(.status_id>0))|map(select(.id|IN($ids[])))')
echo "----去重后的tournament:"$tournaments"------"

# 一二级赛程关系
find_children(){
  pairs=$(cat season_match.json|jq -r '.[0].results |map(select(.status_id>0))|map(select(.match_ids|length>0))|.[]|.id as $id|.match_ids[]
  |"\($id)\t\(.)"')
  while IFS=$'\t' read -r pid id;do
    # printf "%s\t%s\n" "$id" "$pid"
    printf "%s\n" $(jq -c -n --arg id "$id" --arg pid "$pid" '{id: $id, pid: $pid}')
  done <<< "$pairs"
}
find_children
