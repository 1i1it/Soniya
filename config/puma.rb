USE_PUMA_WORKERS = $prod
if USE_PUMA_WORKERS
  workers Integer(ENV['WEB_CONCURRENCY'] || 1)
  threads_count = Integer(ENV['MAX_THREADS'] || 1)
  threads threads_count, threads_count

  preload_app!

  rackup      DefaultRackup
  port        ENV['PORT']     || 9292
  environment ENV['RACK_ENV'] || 'development'
end