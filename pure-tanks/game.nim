# std lib
import sequtils
import sugar

# app imports
import types
import vector

func player_forward(info: UpdateInfo, player: Player): Player =
  # returns the resulting player, after applying the "forward" command
  let distance = info.config.playerspeed * info.config.timemod * (float) delta_t
  let new_position = move(player.position, player.angle, distance)
  return Player(angle: player.angle,
                kills: player.kills,
                deaths: player.deaths,
                name: player.name,
                position: newposition)


func get_player(info: UpdateInfo, name: Name): Player =
    ## returns Player matching Name
    let matching_players = filter(info.state.players, p => p.name == name)
    assert(len(matching_players) == 1, "Must be one Player matching Name.")
    return matching_players[0]


func handle_move_command(info: UpdateInfo, command: Command): GameState =
    ## return GameState after handling exactly one Command
    let player = info.get_player(command.name)

    # table mapping Actions to move functions
    # TODO: complete movement functions
    let move_functions = {
      forward: player_forward,
      backward: nil,
      left: nil,
      right: nil
    }.toTable

    # apply relevant move function to player matching command
    let new_players = map(players, p => movefuncs[cmd.action](p) if p == player)

    # assemble and return new game state
    let new_state = GameState(
      players: new_players,
      projectiles: state.projectiles,

    )
    return new_state



func update*(state: GameState, config: Config,
            delta_t: int, commands: openArray[Command]): GameState =

  for cmd in commands:
    let new_state = handle_player_command(state, config, delta_t, cmd)

  return new_state


