# std lib
import sequtils
import tables
import sugar

# app imports
import types
import vector

func player_forward(info: UpdateInfo, player: Player): Player =
  ## returns the resulting Player object,
  ## after applying the "forward" Command
  let distance = info.config.playerspeed * info.config.timemod * (float) info.delta_t
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


func handle_move_command(info: UpdateInfo, cmd: Command): GameState =
    ## return GameState after handling exactly one Command

    # table mapping Actions to move functions
    # TODO: complete movement functions
    const move_functions = {
      forward: player_forward,
      backward: nil,
      left: nil,
      right: nil
    }.toTable

    # find the command-issuing player
    let player = info.get_player(cmd.name)

    # apply relevant move function to command-issuing player only
    func apply_function(p: Player): Player =
      if p == player:
        # call function found in move_funcions table
        return move_functions[cmd.action](info, p)
      else:
        return p
    let new_players = map(info.state.players, apply_function)

    # assemble and return new game state
    let new_state = GameState(
      players: new_players,
      projectiles: info.state.projectiles,
      map: info.state.map
    )
    return new_state


func update*(info: UpdateInfo, commands: seq[Command]): GameState =
  ## Progresses GameState one tick (by `delta_time`),
  ## by executing all player-issued Commands and moving projectiles

  func apply_command(state: GameState, cmd: Command): GameState =
    ## returns the gamestate achieved after executing exactly one command
    let finfo = UpdateInfo(state: state,
                           config: info.config,
                           delta_t: info.delta_t)
    return handle_move_command(finfo, cmd)

  # apply all commands in succession, returning the final resulting GameState
  let new_state: GameState = foldl(commands, apply_command(a, b), info.state)
  return new_state
