web: REDIS_PROVIDER=REDISCLOUD_URL bundle exec rackup examples/heroku/config.ru -p $PORT
worker: REDIS_PROVIDER=REDISCLOUD_URL bundle exec sidekiq -r ./examples/heroku/app.rb
