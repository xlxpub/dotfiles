你只需在 trpc_go.yaml 中开启 admin 服务（当前你的配置里没有）：
  server:
    admin:
      ip: 127.0.0.1    # 监听地址
      port: 9028        # 默认端口
      # read_timeout: 3000
      # write_timeout: 60000

  启动后直接访问：

  # CPU profile（30秒采样）
  go tool pprof http://127.0.0.1:9028/debug/pprof/profile?seconds=30

  # 堆内存
  go tool pprof http://127.0.0.1:9028/debug/pprof/heap

  # goroutine
  curl http://127.0.0.1:9028/debug/pprof/goroutine?debug=1

  # trace（分析调度）
  curl -o trace.out http://127.0.0.1:9028/debug/pprof/trace?seconds=10
  go tool trace trace.out

  # 火焰图（需安装 graphviz）
  go tool pprof -http=:8081 http://127.0.0.1:9028/debug/pprof/profile?seconds=30

  不需要改任何代码，加一行 yaml 配置就行。


