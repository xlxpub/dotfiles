COOKIE="${CMS_COOKIE:?请设置CMS_COOKIE环境变量"}
echo "COOKIE:${COOKIE};"
exit 0
  curl 'http://cms.video.cloud.cctv.com/api/sports/program/update?env=PROD&classification_type=event' \
  -H 'Content-Type: application/json' \
  -H "Cookie:${CMS_COOKIE}" \
  -d '{"epg_id":"WSIC_2026_5432307","has_match_data":1}'
