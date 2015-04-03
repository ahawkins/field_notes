TESTS:=$(wildcard test/*_test.rb)

Gemfile.lock: Gemfile
	bundle install

.PHONY: test
test: Gemfile.lock
	@ruby -I$(CURDIR) $(foreach test,$(TESTS),-r $(test)) -e "exit"
