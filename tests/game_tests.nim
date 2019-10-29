import unittest, math
import types, game, mathutils

suite "Game logic tests":
  setup:
    let state = GameState(
      projectiles: @[],
      players: @[
        Player(
          name: Name("John"),
          shape: Rect(
            angle: Angle(0),  #  facing right
            pos: Position(x: 100.0, y: 100.0),
            width: 10,
            height: 10
          ),
          kills: 3,
          deaths: 1,
        ),
        Player(
          name: Name("Peter"),
          shape: Rect(
            angle: Angle(PI),  #  facing left
            pos: Position(x: 200.0, y: 200.0),
            width: 10,
            height: 10
          ),
          kills: 5,
          deaths: 2,
        )
      ],
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
    check(newstate.players[0].shape.pos == Position(x: 200.0, y: 100.0))
    check(newstate.players[1].shape.pos == Position(x: 100.0, y: 200.0))
  

  test "simple move backward":
    let commands = @[
      Command((name: Name("John"), action: backward)),
      Command((name: Name("Peter"), action: backward))
    ]
    let newstate = update(state, config, 100, commands)
    check(newstate.players[0].shape.pos == Position(x: 0.0, y: 100.0))
    check(newstate.players[1].shape.pos == Position(x: 300.0, y: 200.0))
  

  test "simple move forward, then backwards":
    let newstateone = update(state, config, 100,
                             @[Command((name: Name("John"), action: forward))])
    check(newstateone.players[0].shape.pos == Position(x: 200.0, y: 100.0))
    let newstatetwo = update(newstateone, config, 100,
                             @[Command((name: Name("John"), action: backward))])
    check(newstatetwo.players[0].shape.pos == Position(x: 100.0, y: 100.0))


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
