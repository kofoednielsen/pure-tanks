# std imports
import options, sequtils, sugar

# game imports
import types, mathutils


# type used to represent possible collisions when moving
type
  CollidableKind* = enum
    PlayerKind,
    ProjectileKind,
    BoxKind

  Collidable* = object
    case kind*: CollidableKind
    of PlayerKind:
      player*: Player
    of ProjectileKind:
      projectile*: Projectile
    of BoxKind:
      box*: Box
    segment*: Segment

  CollOption = tuple[collidable: Collidable,
                        startp: Point,
                        collp: Option[Point]]


func `<`(a, b: CollOption): bool =
  ## Compares CollOptions (in order to easily find minimum)
  (len(Segment(a: a.startp, b: a.collp.get())) <
   len(Segment(a: b.startp, b: b.collp.get())))


func collision_points*(config: Config, seg: Segment): seq[Point] =
  ## Get collision Points on Segment
  let dist = config.collisionpointdist
  let length = len(seg)
  let npoints = int(length/dist)
  let scalars = to_seq(0..npoints).map(i => float(i) * dist / length)
  return map(scalars, s => point_at_scalar(seg, s))


func collision_points*(config: Config, poly: Polygon): seq[Point] =
  ## Get collision Points on surface of Polygon
  poly.segments.map(seg => collision_points(config, seg)).concat()

func get_collidables*(state: GameState, player: Player): seq[Collidable] =
  ## make Collidables of all game objects (except currently moving Player)
  let otherplayers = state.players.filter(p => p != player)
  let
    playercolls: seq[Collidable] = otherplayers.map(
      p => map(p.shape.segments,
        s => Collidable(kind: PlayerKind,
                        player: p,
                        segment: s))).concat().concat()
    projectilecolls: seq[Collidable] = state.projectiles.map(
      p => map(p.shape.segments,
        s => Collidable(kind: ProjectileKind,
                        projectile: p,
                        segment: s))).concat().concat()
    boxcolls: seq[Collidable] = state.map.map(
      b => map(b.shape.segments,
        s => Collidable(kind: BoxKind,
                        box: b,
                        segment: s))).concat().concat()
  return playercolls & projectilecolls & boxcolls


func linear_move_func*(direction: int): auto =
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

    let collidables: seq[Collidable] = get_collidables(info.state, player)

    # wtf
    let colloptions: seq[CollOption] = map(movesegs,
      ms => map(collidables,
        coll => (collidable: coll,
                 startp: ms.a,
                 collp: intersection(coll.segment, ms)))).concat()
    # i give up
    let collisions: seq[CollOption] = colloptions.filter(co => co.collp.is_some())

    # end me
    let mvdist = func(): float =
      if len(collisions) == 0:
        return distance
      let closest = min(collisions)
      return Segment(a: closest.startp,
                     b: closest.collp.get()).len()

    let newshape = move(player.shape, mvdist())
    return Player(shape: newshape,
                  kills: player.kills,
                  deaths: player.deaths,
                  name: player.name)


func rotate_move_func*(direction: int): auto =
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

