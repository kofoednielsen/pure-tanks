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
    let poly = Polygon(
      center: Point(x: 0, y: 0),
      angle: 0,
      segments: @[]
    )

  test "quarter rotate":
    let rotated = rotate(poly, PI / 2)
    check(rotated.angle =~ Angle(PI / 2))

  test "full rotate":
    let rotated = rotate(poly, 2 * PI)
    check(rotated.angle =~ 0)


suite "intersection tests":
  setup:
    let intersectingseg1 = Segment(
      a: Point(x: 0, y: 0),
      b: Point(x: 2, y: 2)
    )
    let intersectingseg2 = Segment(
      a: Point(x: 0, y: 2),
      b: Point(x: 2, y: 0)
    )
    let parallel1 = Segment(
      a: Point(x: 0, y: 40),
      b: Point(x: 5, y: 40)
    )
    let parallel2 = Segment(
      a: Point(x: 0, y: 5),
      b: Point(x: 50, y: 50)
    )

  test "simple intersection":
    let isect = intersection(intersectingseg1,
                             intersectingseg2)
    check(isect.get() =~ Point(x: 1, y: 1))

  test "parallels dont intersect":
    let isect = intersection(parallel1, parallel2)
    check(isect.is_none())

  test "non-intersecting lines":
    let isect = intersection(intersectingseg1, parallel1)
    check(isect.is_none())
