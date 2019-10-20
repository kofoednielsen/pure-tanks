import unittest, strutils, math
import types, game


proc `=~` *(x, y: float): bool =
  ## Define `=~` operator for approximate float comparisions
  const eps = 1.0e-7
  result = abs(x - y) < eps


suite "Game logic tests":
  setup:
    let state = GameState(
      projectiles: @[],
      players: @[
        Player(
          name: Name("John"),
          angle: Angle(0),  #  facing right
          position: Position([100.0, 100.0]),
          kills: 3,
          deaths: 1,
        ),
        Player(
          name: Name("Peter"),
          angle: Angle(PI),  #  facing left
          position: Position([200.0, 200.0]),
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
      let newstate = update(state, config, 100, commands)
  

  test "simple move forward":
    let commands = @[
      Command((name: Name("John"), action: forward)),
      Command((name: Name("Peter"), action: forward))
    ]
    let newstate = update(state, config, 100, commands)
    check(newstate.players[0].position == Position([200.0, 100.0]))
    check(newstate.players[1].position == Position([100.0, 200.0]))
  

  test "simple move backward":
    let commands = @[
      Command((name: Name("John"), action: backward)),
      Command((name: Name("Peter"), action: backward))
    ]
    let newstate = update(state, config, 100, commands)
    check(newstate.players[0].position == Position([0.0, 100.0]))
    check(newstate.players[1].position == Position([300.0, 200.0]))
  

  test "simple move forward, then backwards":
    let newstateone = update(state, config, 100,
                          @[Command((name: Name("John"), action: forward))])
    check(newstateone.players[0].position == Position([200.0, 100.0]))
    let newstatetwo = update(newstateone, config, 100,
                          @[Command((name: Name("John"), action: backward))])
    check(newstatetwo.players[0].position == Position([100.0, 100.0]))


  test "simple rotate":
    let commands = @[
      Command((name: Name("John"), action: clockwise)),
      Command((name: Name("Peter"), action: counterclockwise))
    ]
    let newstate = update(state, config, 8, commands)
    check(newstate.players[0].angle =~ Angle(0))
    check(newstate.players[1].angle =~ Angle(PI))

  test "more interesting rotate":
    let commands = @[
      Command((name: Name("John"), action: clockwise)),
      Command((name: Name("Peter"), action: counterclockwise))
    ]
    let newstate = update(state, config, 3, commands)
    check(newstate.players[0].angle == Angle(-3 * (PI / 4)))
    check(newstate.players[1].angle == Angle(-PI / 4))
