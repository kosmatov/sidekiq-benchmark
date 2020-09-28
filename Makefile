.PHONY: test

DOCKER_CONSOLE := docker-compose run -w /app$(APP_PATH) --rm console
PROJECT_NAME ?= $(shell basename $(shell pwd))

container:
	docker-compose build
	$(DOCKER_CONSOLE) bundle install

bundle bundle_install bundle_update:
	$(eval bundle_cmd ?= $(shell echo $@ | tr _ ' '))
	$(DOCKER_CONSOLE) $(bundle_cmd)
ifndef APP_PATH
	APP_PATH=/examples/heroku make $@
endif

build:
	$(DOCKER_CONSOLE) gem build $(PROJECT_NAME).gemspec

clean:
	$(DOCKER_CONSOLE) rm *.gem

test:
	$(DOCKER_CONSOLE) bundle exec rake test

push:
	$(eval gem_file ?= $(shell find -name $(PROJECT_NAME)\*.gem -print | sort | tail -1))
	$(DOCKER_CONSOLE) gem push $(gem_file)

console:
	$(DOCKER_CONSOLE)
