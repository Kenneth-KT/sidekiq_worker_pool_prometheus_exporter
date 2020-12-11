Gem::Specification.new do |s|
  s.name        = 'sidekiq_worker_pool_prometheus_exporter'
  s.version     = '1.0.0'
  s.date        = '2020-12-12'
  s.summary     = "A lightweight gem for exporting per process Sidekiq worker pool stats to Prometheus, running the same Ruby process"
  s.description = "A lightweight gem for exporting per process Sidekiq worker pool stats to Prometheus, running the same Ruby process"
  s.authors     = ["Kenneth Law"]
  s.email       = 'cyt05108@gmail.com'
  s.files       = ["lib/sidekiq_worker_pool_prometheus_exporter.rb"]
  s.homepage    =
    'https://github.com/Kenneth-KT/sidekiq_worker_pool_prometheus_exporter'
  s.license       = 'MIT'
  s.add_runtime_dependency 'webrick'
end
