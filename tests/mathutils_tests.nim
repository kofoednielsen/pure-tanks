# std imports
import unittest, strutils, math

# app imports
import mathutils, types

suite "wrap_angle tests":
  test "test 2 PI wraps to 0 PI":
    check(wrap_angle(2 * PI) =~ 0)

  test "test 7 PI/4 wraps to -PI/4":
    check(wrap_angle(7 * PI/4) =~ -PI/4)

  test "test -7 PI/4 wraps to PI/4":
    check(wrap_angle(-7 * PI/4) =~ PI/4)


suite "rotate tests":
  setup:
    let rect = Rect(
      pos: Position(x: 0, y: 0),
      width: 0,
      height: 0,
      angle: 0
    )

  test "quarter rotate":
    let rotated = rotate(rect, PI / 2)
    check(rotated.angle =~ Angle(PI / 2))

  test "full rotate":
    let rotated = rotate(rect, 2 * PI)
    check(rotated.angle =~ 0)
