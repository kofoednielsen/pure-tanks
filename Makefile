
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

run:
	nim compile --out:./build/pure-tanks ./pure-tanks/frontend.nim 
	./build/pure-tanks

$(TESTS): clean
	@-nim c \
	-p:pure-tanks/ \
	--out:build/$@ \
	--verbosity:0 \
	--hint[Processing]:off \
	tests/$@.nim \

clean:
	rm -r ./build/ || true
