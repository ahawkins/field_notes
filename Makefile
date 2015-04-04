TESTS:=$(wildcard test/*_test.rb)

tmp/scratch:
	mkdir -p $@

.PHONY: test-src
test-src:
	@ruby -I$(CURDIR) $(foreach test,$(TESTS),-r $(test)) -e "exit"

.PHONY: test-util
test-util: tmp/scratch
	env UTIL=$(CURDIR)/util/fn FIELD_NOTES_PATH=tmp/scratch bats test/util_test.sh

.PHONY: test
test: test-src test-util

.PHONY: clean
clean:
	rm -rf tmp/scratch
