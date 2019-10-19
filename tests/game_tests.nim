import unittest, strutils
import game, types
suite "Game logic tests":
  setup:
    echo "setup"
  
  teardown:
    echo "teardown"
  
  test "simple move forward":
    let players = @[
      Player(
        name: "John",
        angle: Angle(0),
        position: Position([100,100]),
        kills: 0,
        deaths: 0,
      )
    ]

    let state = GameState(
      projectiles: @[],
      players: players,
      map: Map(@[])
    )

    let config = Config(
      timemod: 1,
      playerspeed: 1,
      projectilespeed: 1.5
    )

    let commands = [
      Command((name: "John", action: parseEnum[Action]("forward")))
    ]
    
    let new_state = update(
     state: state,
     config: config,
     delta_t: 100,
     commands: commands
    )

    check(new_state.players[0].position == Position([100,0]))
