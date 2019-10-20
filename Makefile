
TESTPATHS = $(wildcard tests/*.nim)
TESTFILES = $(subst tests/,,$(TESTPATHS))
TESTS = $(subst .nim,,$(TESTFILES))

test: $(TESTS)

$(TESTS):
	@-nim c \
	--run \
	-p:pure-tanks/ \
	--out:build/$@ \
	--verbosity:0 \
	--hint[Processing]:off \
	tests/$@.nim \

clean:
	rm -r ./build/
