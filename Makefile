

test:
	nim c -r -p:pure-tanks/ tests/game_tests.nim

compile-test:
	nim c -p:pure-tanks/ tests/game_tests.nim
