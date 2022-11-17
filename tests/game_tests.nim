import unittest, math
import types, game, mathutils

suite "Game logic tests":
  setup:
    # 100x100 square, centered at (100, 100), facing right
    let hundredsquare_segments = @[
      Segment(a: Point(x: 50, y: 50),    # (50, 50)    (150, 50)
              b: Point(x: 150, y: 50)),  #      +---------+
      Segment(a: Point(x: 150, y: 50),   #      |         |
              b: Point(x: 150, y: 150)), #      |  (100,  |
      Segment(a: Point(x: 150, y: 150),  #      |   100)  |
              b: Point(x: 50, y: 150)),  #      |         |
      Segment(a: Point(x: 50, y: 150),   #      +---------+
              b: Point(x: 50, y: 50))    # (50, 150)   (150, 150)
    ]
    let john = Player(
      name: Name("John"),
      shape: Polygon(
        angle: Angle(0),
        segments: hundredsquare_segments,
        center: Point(x: 100, y: 100),
      ),
      kills: 3,
      deaths: 1
    )
    let backwards_john = Player(
      name: Name("John"),
      shape: Polygon(
        angle: Angle(PI),
        segments: hundredsquare_segments,
        center: Point(x: 100, y: 100),
      ),
      kills: 3,
      deaths: 1
    )

    # 100x100 square, centered at (300, 100)
    # (leftmost points are x=250, y=50..150)
    let johnblockersquare = Polygon(
      angle: Angle(0),
      center: Point(x: 200, y: 150),
      segments: @[
        Segment(a: Point(x: 250, y: 100),  # (250, 100)   (350, 100)
                b: Point(x: 350, y: 100)), #      +---------+
        Segment(a: Point(x: 350, y: 100),  #      |         |
                b: Point(x: 350, y: 200)), #      |  (200,  |
        Segment(a: Point(x: 350, y: 200),  #      |   150)  |
                b: Point(x: 250, y: 200)), #      |         |
        Segment(a: Point(x: 250, y: 200),  #      +---------+
                b: Point(x: 250, y: 100))  # (250, 200)   (350, 200)
      ]
    )
    let johnblocker = Player(
      name: Name("JohnBlocker"),
      shape: johnblockersquare,
      kills: 1337,
      deaths: 0
    )

    let peter = Player(
      name: Name("Peter"),
      shape: Polygon(
        angle: Angle(PI),  #  facing left
        center: Point(x: 2000.0, y: 2000.0),
        segments: @[
          Segment(a: Point(x: 1950, y: 1950),  # (1950, 1950)(2050, 1950)
                  b: Point(x: 2050, y: 1950)), #      +---------+
          Segment(a: Point(x: 2050, y: 1950),  #      |         |
                  b: Point(x: 2050, y: 2050)), #      |  (100,  |
          Segment(a: Point(x: 2050, y: 2050),  #      |   100)  |
                  b: Point(x: 1950, y: 2050)), #      |         |
          Segment(a: Point(x: 1950, y: 2050),  #      +---------+
                  b: Point(x: 1950, y: 1950))  # (1950, 2050)(2050, 2050)
        ]
      ),
      kills: 5,
      deaths: 2
    )

    # a totally flat and very small wall
    # designed for peter to run into
    let peterblockersquare = Polygon(
      angle: Angle(0),
      center: Point(x: 200, y: 150),
      segments: @[
        Segment(a: Point(x: 0, y: 1999),
                b: Point(x: 0, y: 2001))
      ]
    )
    let peterblocker = Player(
      name: Name("PeterBlocker"),
      shape: peterblockersquare,
      kills: 5318008,
      deaths: 0
    )

    let state = GameState(
      projectiles: @[],
      players: @[john, peter, johnblocker, peterblocker],
      map: Map(@[])
    )

    let state_with_backwards_john = GameState(
      projectiles: @[],
      players: @[backwards_john, peter, johnblocker, peterblocker],
      map: Map(@[])
    )

    let config = Config(
      timemod: 1,
      movementspeed: 1,
      rotationspeed: PI/4,
      projectilespeed: 1.5,
      collisionpointdist: 1
    )


  test "more than one command per player":
    let commands = @[
      Command((name: Name("John"), action: forward)),
      Command((name: Name("John"), action: backward)),
    ]
    expect(AssertionError):
      discard update(state, config, 100, commands)
  

  test "simple move forward":
    let commands = @[
      Command((name: Name("John"), action: forward)),
      Command((name: Name("Peter"), action: forward))
    ]
    let newstate = update(state, config, 100, commands)
    check(newstate.players[0].shape.center == Point(x: 200.0, y: 100.0))
    check(newstate.players[1].shape.center == Point(x: 1900.0, y: 2000.0))
  

  test "simple move backward":
    let commands = @[
      Command((name: Name("John"), action: backward)),
      Command((name: Name("Peter"), action: backward))
    ]
    let newstate = update(state, config, 100, commands)
    check(newstate.players[0].shape.center == Point(x: 0.0, y: 100.0))
    check(newstate.players[1].shape.center == Point(x: 2100.0, y: 2000.0))
  

  test "simple move forward, then backwards":
    let newstateone = update(state, config, 10,
                             @[Command((name: Name("John"), action: forward))])
    check(newstateone.players[0].shape.center == Point(x: 110.0, y: 100.0))
    let newstatetwo = update(newstateone, config, 10,
                             @[Command((name: Name("John"), action: backward))])
    check(newstatetwo.players[0].shape.center == Point(x: 100.0, y: 100.0))


  test "simple rotate":
    let commands = @[
      Command((name: Name("John"), action: clockwise)),
      Command((name: Name("Peter"), action: counterclockwise))
    ]
    let newstate = update(state, config, 8, commands)
    check(newstate.players[0].shape.angle =~ Angle(0))
    check(newstate.players[1].shape.angle =~ Angle(PI))


  test "more interesting rotate":
    let commands = @[
      Command((name: Name("John"), action: clockwise)),
      Command((name: Name("Peter"), action: counterclockwise))
    ]
    let newstate = update(state, config, 3, commands)
    check(newstate.players[0].shape.angle =~ Angle(-3 * (PI / 4)))
    check(newstate.players[1].shape.angle =~ Angle(-PI / 4))


  test "blocked move":
    let movecmd = Command((name: Name("John"), action: forward))
    let newstate = update(state, config, 1000, @[movecmd])
    let movedjohn = newstate.players[0]
    check(movedjohn.shape.center == Point(x: 200, y: 100))

  test "blocked move backwards":
    let movecmd = Command((name: Name("John"), action: backward))
    let newstate = update(state_with_backwards_john, config, 1000, @[movecmd])
    let movedjohn = newstate.players[0]
    check(movedjohn.shape.center.x =~ 200)
    check(movedjohn.shape.center.y =~ 100)


  test "move blocked with very small shape":
    let movecmd = Command((name: Name("Peter"), action: forward))
    let newstate = update(state, config, 3000, @[movecmd])
    let movedpeter = newstate.players[1]
    check(movedpeter.shape.center =~ Point(x: 50, y: 2000))
