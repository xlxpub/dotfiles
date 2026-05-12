#!/bin/bash

# 检索服务调试脚本，source 后按需调用：search_match / search_player / search_schedule

#prefix="https://sailing.testsite.woa.com/api/retrieval"
prefix="http://localhost:8099"
json_header="Content-Type: application/json"

# 赛事检索
search_match() {
  curl -s -X POST "${prefix}/match/retrieval" \
    -H "$json_header" \
    -d '{
      "index": "match",
      "match_project_names": ["足球"],
      "short_title": "世界杯",
      "limit": 2
    }' | jq .
}

# 球员检索
search_player() {
  curl -s -X POST "${prefix}/player/retrieval" \
    -H "$json_header" \
    -H "Cookie: $cookie" \
    -d '{
      "index": "player",
      "name": "梅西",
      "project_id":"FBL"
    }' | jq .
}

# 赛程/节目单检索
search_schedule() {
  local play_time="${1:-$(date '+%Y-%m-%d 00:00')}"
  curl -s -X POST "${prefix}/knowledge/retrieval" \
    -H "$json_header" \
    -H "Cookie: $cookie" \
    -d "{
      \"index\": \"program\",
      \"play_time_gte\": \"${play_time}\"
    }" | jq .
}

# 知识库检索
search_knowledge() {
  local query="${1:-'wtt赛制'}"
  local req="{
                  \"index\": \"knowledge_base\",
                  \"project\": \"TTE\",
                  \"query\": \"${query}\"
                }"
  echo  "body: $req"
  curl -s -X POST "${prefix}/knowledgebase/retrieval" \
    -H "$json_header" \
    -d  "$req"| jq .
}

x(){
 curl -s -X POST "${prefix}/knowledge/retrieval" \
    -H "$json_header" \
    -d '{"player_names":["孙颖莎"],"play_time_gte":"2025-03-31 00:00:00","play_time_lte":"2026-04-30 23:59:59","size":50,"index":"program"}'| jq .
}

# 2026中超世界排名
curl -X POST "${prefix}/match/retrieval" \
    -H "$json_header" \
    -d '{
      "index": "match",
      "match_project_names": ["足球"],
      "short_title": "2026中超",
      "limit": 10
    }' | jq .

curl  -X POST "${prefix}/boardrank/retrieval" \
    -H "$json_header" \
    -d '{"match_id":"kVrJS6ThVPQHs2Bi_S1IVw==","subject_name":"山东泰山"}'|jq
