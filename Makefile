
# tests/mytest.nim -> mytest
TESTPATHS = $(wildcard tests/*.nim)        # path to test code
TESTFILES = $(subst tests/,,$(TESTPATHS))  # basenames of test files
TESTS = $(subst .nim,,$(TESTFILES))        # strip extension

test: $(TESTS)
	# run tests
	set -e; \
	for test in $^; do \
		./build/$${test}; \
	done;

$(TESTS):
	@-nim c \
	-p:pure-tanks/ \
	--out:build/$@ \
	--verbosity:0 \
	--hint[Processing]:off \
	tests/$@.nim \

clean:
	rm -r ./build/
