# std imports
import unittest
# app imports
import movement, types


suite "movement tests":
  setup:
    let config = Config(
      collisionpointdist: 1
    )
  test "test collision_points on single segment":
    let seg = Segment(a: Point(x: 0, y: 0),
                      b: Point(x: 0, y: 3))
    let expected = @[
      Point(x: 0, y: 0),
      Point(x: 0, y: 1),
      Point(x: 0, y: 2),
      Point(x: 0, y: 3)
    ]
    check(collision_points(config, seg) == expected)
