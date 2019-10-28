# std lib
import sequtils, tables, sugar, math
# app imports
import types, mathutils

func linear_move_func(direction: int): auto =
  ## Returns a function for moving a player either forwards or backward
  assert(direction in [-1, 1], "Only allowed directions are 1 and -1")
  return func(info: UpdateInfo, player: Player): Player =
    # Move the player and return the resulting player object
    let distance = (info.config.movementspeed *
                    info.config.timemod *
                    float(info.dt) *
                    float(direction))  # direction coefficient

    let newposition = move(player.position, player.angle, distance)
    return Player(angle: player.angle,
                  kills: player.kills,
                  deaths: player.deaths,
                  name: player.name,
                  position: newposition)


func rotate_move_func(direction: int): auto =
  assert(direction in [-1, 1], "Only allowed directions are 1 and -1")
  return func(info: UpdateInfo, player: Player): Player =
    ## Return the Player after rotating in direction indicated by `coef`
    let angledelta = (info.config.rotationspeed *
                      info.config.timemod *
                      float(info.dt) *
                      float(direction))
    let newangle = player.angle + angledelta

    # wrap angle into range [-PI;PI]
    let wrappedangle = wrap_angle(newangle)
    assert((-1 * PI) <= wrappedangle and wrappedangle <= PI,
           "Got angle outside range [-PI;PI]")

    return Player(angle: wrappedangle,
                  kills: player.kills,
                  deaths: player.deaths,
                  name: player.name,
                  position: player.position)


func get_player(info: UpdateInfo, name: Name): Player =
    ## returns Player matching Name
    let matches = filter(info.state.players, p => p.name == name)
    assert(len(matches) == 1, "Must be one Player matching Name.")
    return matches[0]


func apply_command(info: UpdateInfo, cmd: Command): UpdateInfo =
    ## return GameState after applying given Command
    
    # table mapping Actions to move functions
    let mvfuncs = {
      counterclockwise: rotate_move_func(1),
      clockwise: rotate_move_func(-1),
      forward: linear_move_func(1),
      backward: linear_move_func(-1)
    }.toTable

    # find the command-issuing player
    let player = info.get_player(cmd.name)
    # get relevant move function
    let mvfunc = mvfuncs[cmd.action]

    # apply relevant move function to command-issuing player only
    let new_players = map(info.state.players,
                          p => (if p == player: mvfunc(info,p) else: p))

    # assemble game state
    let newstate = GameState(
      players: newplayers,
      projectiles: info.state.projectiles,
      map: info.state.map
    )
    
    # returns UpdateInfo because it makes the fold in `update` more convinient
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
