curl http://localhost:3000/api/tteagent/mcp/chat \
  -H 'Content-Type: application/json' \
-d '{
  "id": 6,
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "_meta": {
      "progressToken": 6
    },
    "arguments": {
      "need_knowledge_list": true,
      "query": "王曼昱世界排名"
    },
    "name": "tteagent"
  }
}
'
