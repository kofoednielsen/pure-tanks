

test:
	nim c --hint[Processing]:off -r -p:pure-tanks/ tests/game_tests.nim

compile-test:
	nim c -p:pure-tanks/ tests/game_tests.nim
