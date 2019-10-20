# std imports
import unittest, strutils, math

#app imports
import mathutils

suite "wrap_angle tests":


  test "test 2 PI wraps to 0 PI":
    check(wrap_angle(2 * PI) =~ 0)


  test "test 7 PI/4 wraps to -PI/4":
    check(wrap_angle(7 * PI/4) =~ -PI/4)


  test "test -7 PI/4 wraps to PI/4":
    check(wrap_angle(-7 * PI/4) =~ PI/4)
