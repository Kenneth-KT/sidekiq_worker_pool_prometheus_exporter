require 'webrick'
require 'json'

class SidekiqWorkerPoolPrometheusExporter
  attr_reader :bind
  attr_reader :port
  attr_reader :resolution
  attr_reader :metrics_prefix

  def initialize(bind: nil, port: nil, resolution: nil, metrics_prefix: nil)
    @bind = bind || ENV['SIDEKIQ_WORKER_POOL_EXPORTER_BIND'] || '0.0.0.0'
    @port = port || ENV['SIDEKIQ_WORKER_POOL_EXPORTER_PORT'] || '9090'
    @resolution = (
      resolution ||
      (Float(ENV['SIDEKIQ_WORKER_POOL_EXPORTER_RESOLUTION']) rescue nil) ||
      1
    )
  end

  def listen
    @server = WEBrick::HTTPServer.new(
      Port: @port,
      BindAddress: @bind,
      Logger: WEBrick::Log.new("/dev/null"),
      AccessLog: WEBrick::Log.new("/dev/null")
    )

    @server.mount_proc '/' do |req, res|
      case req.path
      when '/metrics'
        handle_metrics(req, res)
      else
        res.status = 404
        res.body = 'Not found. The exporter server only listens on /metrics'
      end
    end

    Thread.new { @server.start }
  end

  private

  attr_reader :cached_at
  attr_reader :cached_stats

  def handle_metrics(_req, res)
    if stats.nil?
      res.status = 503
      res.body = 'Metrics to export are unavailable at the moment.'  
    else
      workers_pool = stats[:workers_pool]
      workers_busy = stats[:workers_busy]

      res.status = 200
      res.body = [
        "sidekiq_workers_pool #{workers_pool}",
        "sidekiq_workers_busy #{workers_busy}"
      ].join("\n")
    end
  end

  def stats
    refresh_stats? ? refresh_stats : cached_stats
  end

  def refresh_stats
    @cached_at = Time.now

    workers_set = Sidekiq::CLI.instance.launcher.manager.workers
    workers_pool = workers_set.size
    workers_busy = workers_set.count(&:job)

    @cached_stats = {
      workers_pool: workers_pool,
      workers_busy: workers_busy
    }
  rescue => e
    nil
  end

  def refresh_stats?
    cached_at.nil? || (Time.now - cached_at) > resolution
  end
end
