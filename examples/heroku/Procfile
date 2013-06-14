web: REDIS_PROVIDER=REDISCLOUD_URL bundle exec rackup config.ru -p $PORT
worker: REDIS_PROVIDER=REDISCLOUD_URL bundle exec sidekiq -r ./app.rb
