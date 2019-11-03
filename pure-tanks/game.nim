# std lib
import sequtils, tables, sugar, math, options
# app imports
import types, mathutils


func collision_points(config: Config, seg: Segment): seq[Point] =
  ## Get collision Points on Segment
  let dist = config.collisionpointdist
  let length = len(seg)
  let npoints = int(length/dist)
  let scalars = to_seq(0..npoints).map(i => float(i) * dist / length)
  return map(scalars, s => point_at_scalar(seg, s))


func collision_points(config: Config, poly: Polygon): seq[Point] =
  ## Get collision Points on surface of Polygon
  poly.segments.map(seg => collision_points(config, seg)).concat()


func linear_move_func(direction: int): auto =
  ## Returns a function for moving a player either forwards or backward
  assert(direction in [-1, 1], "Only allowed directions are 1 and -1")
  return func(info: UpdateInfo, player: Player): Player =
    # Move the player and return the resulting player object
    let distance = (info.config.movementspeed *
                    info.config.timemod *
                    float(info.dt) *
                    float(direction))  # direction coefficient

    # ideal movement vector (if we don't collide, do this)
    let idealvec = to_vector(player.shape.angle, distance)

    # colliding points on Polygon
    let collpoints = collision_points(info.config, player.shape)

    # movement lines for each collision point
    let movesegs = collpoints.map(p => Segment(a: p, b: p.translate(idealvec)))

    # get Segments of all Collidables (except currently moving Player)
    # and wrap the actual Collidable type in a Collidable variant object
    # results in a seq[seq[seq[Segment], Collidable]]
    let otherplayers = info.state.players.filter(p => p != player)
    let
      playercolls: seq[Collidable] = otherplayers.map(
        p => map(p.shape.segments, s => Collidable(kind: PlayerKind,
                                                   player: p,
                                                   segment: s))).concat().concat()
      projectilecolls: seq[Collidable] = info.state.projectiles.map(
        p => map(p.shape.segments, s => Collidable(kind: ProjectileKind,
                                                   projectile: p,
                                                   segment: s))).concat().concat()
      boxcolls: seq[Collidable] = info.state.map.map(
        b => map(b.shape.segments, s => Collidable(kind: BoxKind,
                                                   box: b,
                                                   segment: s))).concat().concat()
    let collidables: seq[Collidable] = playercolls & projectilecolls & boxcolls

    type CollOption = tuple[collidable: Collidable,
                            startp: Point,
                            collp: Option[Point]]

    let colloptions: seq[CollOption] = map(movesegs,
      ms => map(collidables,
        coll => (collidable: coll,
                 startp: ms.a,
                 collp: intersection(coll.segment, ms)))).concat().concat()

    let collisions: seq[CollOption] = colloptions.filter(co => co.collp.is_some())

    func `<`(a, b: CollOption): bool =
      ## Compares CollOptions (in order to find minimum)
      (len(Segment(a: a.startp, b: a.collp.get())) <
       len(Segment(a: b.startp, b: b.collp.get())))

    let mvdist = func(): float =
      if 0 < len(collisions):
        let closest = min(collisions)
        return Segment(a: closest.startp,
                       b: closest.collp.get()).len()
      else:
        return distance

    let newshape = move(player.shape, mvdist())
    return Player(shape: newshape,
                  kills: player.kills,
                  deaths: player.deaths,
                  name: player.name)


func rotate_move_func(direction: int): auto =
  ## Returns a function for rotating a player either clockwise 
  ## or counterclockwise
  assert(direction in [-1, 1], "Only allowed directions are 1 and -1")
  return func(info: UpdateInfo, player: Player): Player =
    ## Return the Player after rotating in direction indicated by `coef`
    let angledelta = (info.config.rotationspeed *
                      info.config.timemod *
                      float(info.dt) *
                      float(direction))
    let newshape = rotate(player.shape, angledelta)
    return Player(shape: newshape,
                  kills: player.kills,
                  deaths: player.deaths,
                  name: player.name)


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
    let newplayers = map(info.state.players,
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
