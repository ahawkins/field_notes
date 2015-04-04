TESTS:=$(wildcard test/*_test.rb)

.PHONY: test
test:
	@ruby -I$(CURDIR) $(foreach test,$(TESTS),-r $(test)) -e "exit"
