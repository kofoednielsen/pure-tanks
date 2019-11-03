import unittest, math
import types, game, mathutils

suite "Game logic tests":
  setup:
    # 100x100 square, centered at (100, 100), facing right
    let hundredsquare = Polygon(
      angle: Angle(0),
      center: Point(x: 100, y: 100),
      segments: @[
        Segment(a: Point(x: 50, y: 50),    # (50, 50)    (150, 50)
                b: Point(x: 150, y: 50)),  #      +---------+
        Segment(a: Point(x: 150, y: 50),   #      |         |
                b: Point(x: 150, y: 150)), #      |  (100,  |
        Segment(a: Point(x: 150, y: 150),  #      |   100)  |
                b: Point(x: 50, y: 150)),  #      |         |
        Segment(a: Point(x: 50, y: 150),   #      +---------+
                b: Point(x: 50, y: 50))    # (50, 150)   (150, 150)
      ]
    )
    let john = Player(
      name: Name("John"),
      shape: hundredsquare,
      kills: 3,
      deaths: 1
    )

    let peter = Player(
      name: Name("Peter"),
      shape: Polygon(
        angle: Angle(PI),  #  facing left
        center: Point(x: 200.0, y: 200.0),
        segments: @[]
      ),
      kills: 5,
      deaths: 2
    )

    let blockingsquare = Polygon(
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
    # 100x100 square, centered at (300, 100)
    # (leftmost points are x=250, y=50..150)
    let johnblocker = Player(
      name: Name("JohnBlocker"),
      shape: blockingsquare,
      kills: 1337,
      deaths: 0
    )

    let state = GameState(
      projectiles: @[],
      players: @[john, peter, johnblocker],
      map: Map(@[])
    )

    let config = Config(
      timemod: 1,
      movementspeed: 1,
      rotationspeed: PI/4,
      projectilespeed: 1.5,
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
    check(newstate.players[1].shape.center == Point(x: 100.0, y: 200.0))
  

  test "simple move backward":
    let commands = @[
      Command((name: Name("John"), action: backward)),
      Command((name: Name("Peter"), action: backward))
    ]
    let newstate = update(state, config, 100, commands)
    check(newstate.players[0].shape.center == Point(x: 0.0, y: 100.0))
    check(newstate.players[1].shape.center == Point(x: 300.0, y: 200.0))
  

  test "simple move forward, then backwards":
    let newstateone = update(state, config, 100,
                             @[Command((name: Name("John"), action: forward))])
    check(newstateone.players[0].shape.center == Point(x: 200.0, y: 100.0))
    let newstatetwo = update(newstateone, config, 100,
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
