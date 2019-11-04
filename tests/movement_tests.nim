# std imports
import unittest, sequtils, sugar
# app imports
import movement, types


suite "movement tests":


  setup:
    let hundredsquare = Polygon(
      angle: Angle(0),
      center: Point(x: 100, y: 100),
      segments: @[
        Segment(a: Point(x: 50, y: 50),    # (50, 50)    (150, 50)
                b: Point(x: 150, y: 50)),  #    +------------+
        Segment(a: Point(x: 150, y: 50),   #    |            |
                b: Point(x: 150, y: 150)), #    | (100, 100) |
        Segment(a: Point(x: 150, y: 150),  #    |            |
                b: Point(x: 50, y: 150)),  #    |            |
        Segment(a: Point(x: 50, y: 150),   #    +------------+
                b: Point(x: 50, y: 50))    # (50, 150)   (150, 150)
      ]
    )
    let blockingsquare = Polygon(
      angle: Angle(0),
      center: Point(x: 200, y: 150),
      segments: @[
        Segment(a: Point(x: 250, y: 100),  # (250, 100)   (350, 100)
                b: Point(x: 350, y: 100)), #     +------------+
        Segment(a: Point(x: 350, y: 100),  #     |            |
                b: Point(x: 350, y: 200)), #     | (200, 150) |
        Segment(a: Point(x: 350, y: 200),  #     |            |
                b: Point(x: 250, y: 200)), #     |            |
        Segment(a: Point(x: 250, y: 200),  #     +------------+
                b: Point(x: 250, y: 100))  # (250, 200)   (350, 200)
      ]
    )

    let config = Config(
      collisionpointdist: 1
    )
    let pa = Player(name: "a",
                        kills: 0,
                        deaths: 0,
                        shape: hundredsquare)
    let pb = Player(name: "b",
                        kills: 0,
                        deaths: 0,
                        shape: blockingsquare)
    let state = GameState(players: @[pa, pb])


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


  test "Test collision points on tiny polygon":
    let tinypoly = Polygon(
      angle: Angle(0),
      center: Point(x: 2, y: 2),
      segments: @[
        Segment(a: Point(x: 0, y: 0),    #   (0, 0)     (4, 0)
                b: Point(x: 4, y: 0)),   #      +---------+
        Segment(a: Point(x: 4, y: 0),    #      |         |
                b: Point(x: 4, y: 4)),   #      |  (2,2)  |
        Segment(a: Point(x: 4, y: 4),    #      |         |
                b: Point(x: 0, y: 4)),   #      |         |
        Segment(a: Point(x: 0, y: 4),    #      +---------+
                b: Point(x: 0, y: 0))    #   (0, 4)      (4, 4)
      ]
    )

    let expected = @[
      Point(x: 0, y: 0),
      Point(x: 1, y: 0),
      Point(x: 2, y: 0),
      Point(x: 3, y: 0),
      Point(x: 4, y: 0),

      Point(x: 4, y: 0),
      Point(x: 4, y: 1),
      Point(x: 4, y: 2),
      Point(x: 4, y: 3),
      Point(x: 4, y: 4),

      Point(x: 4, y: 4),
      Point(x: 3, y: 4),
      Point(x: 2, y: 4),
      Point(x: 1, y: 4),
      Point(x: 0, y: 4),

      Point(x: 0, y: 4),
      Point(x: 0, y: 3),
      Point(x: 0, y: 2),
      Point(x: 0, y: 1),
      Point(x: 0, y: 0),
    ]
    check(collision_points(config, tinypoly) == expected)

  test "test get_collidables":
    let expected : seq[Collidable] = @[
       Collidable(kind: PlayerKind,
                  player: pa,
                  segment: pa.shape.segments[0]),
       Collidable(kind: PlayerKind,
                  player: pa,
                  segment: pa.shape.segments[1]),
       Collidable(kind: PlayerKind,
                  player: pa,
                  segment: pa.shape.segments[2]),
       Collidable(kind: PlayerKind,
                  player: pa,
                  segment: pa.shape.segments[3])
    ]

    check(get_collidables(state, pb).map(c => c.kind) == expected.map(c => c.kind))
    check(get_collidables(state, pb).map(c => c.player) == expected.map(c => c.player))
    check(get_collidables(state, pb).map(c => c.segment) == expected.map(c => c.segment))
