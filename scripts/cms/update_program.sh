: ${CMS:?"请设置CMS环境变量"}
echo "CMS:${CMS};"
  curl 'http://cms.video.cloud.cctv.com/api/sports/program/update?env=PROD&classification_type=event' \
  -H 'Content-Type: application/json' \
  -H "Cookie:${CMS_COOKIE}" \
  -d '{"epg_id":"WSIC_2026_5432307","has_match_data":1}'
