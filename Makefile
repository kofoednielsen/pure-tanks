

test:
	nim c --hint[Processing]:off --verbosity:0 -r -p:pure-tanks/ tests/mathutils_tests.nim
	nim c --hint[Processing]:off --verbosity:0 -r -p:pure-tanks/ tests/game_tests.nim
