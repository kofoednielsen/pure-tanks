# std imports
import unittest, strutils, math, options

# app imports
import mathutils, types


suite "wrap_angle tests":
  test "test 2 PI wraps to 0 PI":
    check(wrap_angle(2 * PI) =~ 0)

  test "test 7 PI/4 wraps to -PI/4":
    check(wrap_angle(7 * PI/4) =~ -PI/4)

  test "test -7 PI/4 wraps to PI/4":
    check(wrap_angle(-7 * PI/4) =~ PI/4)


suite "vector tests":
  setup:
    let vec1 = Vector(x: 2, y: 2)
    let vec2 = Vector(x: -2, y: 2)
    let vec3 = Vector(x: 5, y: 9)

  test "vector length":
    check(len(vec1) =~ 2.82842712474619)
    check(len(vec2) =~ 2.82842712474619)
    check(len(vec3) =~ 10.295630140987)

  test "vector dot product":
    check(dot(vec1, vec2) == 0.0)
    check(dot(vec2, vec3) == 8.0)


suite "rotate tests":
  setup:
    let poly = Polygon(
      center: Point(x: 0, y: 0),
      angle: 0,
      segments: @[]
    )
    let firstquadrantpoint = Point(x: 1, y: 1)

  test "quarter rotate polygon - check angle":
    let rotated = rotate(poly, PI / 2)
    check(rotated.angle =~ Angle(PI / 2))

  test "full rotate polygon - check angle":
    let rotated = rotate(poly, 2 * PI)
    check(rotated.angle =~ 0)

  test "rotate point PI radians around origin":
    let rotated = rotate(firstquadrantpoint,
                         Point(x: 0, y: 0), PI)
    check(rotated =~ Point(x: -1, y: -1))

  test "rotate point PI radians around (2,2)":
    let rotated = rotate(firstquadrantpoint,
                         Point(x: 2, y: 2), PI)
    check(rotated =~ Point(x: 3, y: 3))


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

  test "test len of segment":
    let seg = Segment(a: Point(x: 4, y: 0),
                      b: Point(x: 4, y: 4))
    let expected = 4.0
    check(len(seg) == expected)

  test "simple segment intersection":
    let isect = intersection(intersectingseg1,
                             intersectingseg2)
    check(isect.get() =~ Point(x: 1, y: 1))

  test "parallel segments dont intersect":
    let isect = intersection(parallel1, parallel2)
    check(isect.is_none())

  test "non-intersecting segments":
    let isect = intersection(intersectingseg1, parallel1)
    check(isect.is_none())


suite "circular arc intersections":
  setup:
    # "half moon" shaped circle segment
    let circle = CircleArc(
      center: Point(x: 0, y: 0),
      radius: 1,
      a: Angle(0),
      b: Angle(PI)
    )
    # line starting at origin going straight up
    let intersectsegment = Segment(a: Point(x: 0, y: 0),
                                   b: Point(x: 0, y: 4))

  test "simple segment and arc intersection":
    let isect = intersection(circle, intersectsegment)
    check(isect.is_some())
    check(isect.get() == Point(x: 0, y: 1))
