# std lib
import sequtils, tables, sugar, math
# app imports
import types, vector

func move_linear(info: UpdateInfo, player: Player, coef: float): Player =
  # Move the player and return the resulting player object
  let distance = (info.config.movementspeed *
                  info.config.timemod *
                  float(info.dt) *
                  coef)  # direction coefficient

  let newposition = move(player.position, player.angle, distance)
  return Player(angle: player.angle,
                kills: player.kills,
                deaths: player.deaths,
                name: player.name,
                position: newposition)


func move_forward(info: UpdateInfo, player: Player): Player =
  ## Returns player after "forward" move.  
  return move_linear(info, player, 1.0)


func move_backward(info: UpdateInfo, player: Player): Player =
  ## Returns player after "backward" move. 
  return move_linear(info, player, -1.0)


func move_rotate(info: UpdateInfo, player: Player, coef: float): Player =
  ## Return the Player after rotating in direction indicated by `coef`
  let angledelta = (info.config.rotationspeed *
                    info.config.timemod *
                    float(info.dt) *
                    coef)
  let newangle = player.angle + angledelta

  # wrap angle into range [-PI;PI]
  # (mysterious piece of maths that does what we want)
  # let wrappedangle = arctan2(sin(newangle), cos(newangle))
  let wrappedangle = wrap_angle(newangle)
  assert((-1 * PI) <= wrappedangle and wrappedangle <= PI,
         "Got angle outside range [-PI;PI]")

  return Player(angle: wrappedangle,
                kills: player.kills,
                deaths: player.deaths,
                name: player.name,
                position: player.position)


func move_counterclockwise(info: UpdateInfo, player: Player): Player =
  ## Return the Player after rotating counterclockwise
  return move_rotate(info, player, 1.0)


func move_clockwise(info: UpdateInfo, player: Player): Player =
  ## Return the Player after rotating clockwise
  return move_rotate(info, player, -1.0)



func get_player(info: UpdateInfo, name: Name): Player =
    ## returns Player matching Name
    let matches = filter(info.state.players, p => p.name == name)
    assert(len(matches) == 1, "Must be one Player matching Name.")
    return matches[0]


func apply_command(info: UpdateInfo, cmd: Command): UpdateInfo =
    ## return GameState after applying given Command
    
    # table mapping Actions to move functions
    # TODO: complete movement functions
    const mvfuncs = {
      forward: move_forward,
      backward: move_backward,
      counterclockwise: move_counterclockwise,
      clockwise: move_clockwise
    }.toTable

    # find the command-issuing player
    let player = info.get_player(cmd.name)
    # get relevant move function
    let mvfunc = mvfuncs[cmd.action]

    # apply relevant move function to command-issuing player only
    let new_players = map(info.state.players,
                          p => (if p == player: mvfunc(info,p) else: p))

    # assemble and return new game state
    let newstate = GameState(
      players: newplayers,
      projectiles: info.state.projectiles,
      map: info.state.map
    )
    
    # returns UpdateInfo because it make the fold in `update` more convinient
    return UpdateInfo(state: newstate,
                      config: info.config,
                      dt: info.dt)


func update*(state: GameState, config: Config, dt: int,
             commands: seq[Command]): GameState =
  ## Progresses GameState one tick, (by `dt`)
  assert(len(commands) == len(deduplicate(map(commands, cmd => cmd.name))),
         "More than one commands from the same player")
  # Group update related info for shorter function calls   
  let info = UpdateInfo(
    state: state,
    config: config,
    dt: dt
  )

  # apply all commands in succession
  let finalinfo: UpdateInfo = foldl(commands, apply_command(a, b), info)
  return finalinfo.state
