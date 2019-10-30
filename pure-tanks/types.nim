# Geometry
type
  Angle* = float  #  radians

  Point* = object
    x*, y*: float

  Segment* = object
    a*, b*: Point

  Polygon* = object
    center*: Point
    segments*: seq[Segment]


# Game objects
type
  Name* = string

  Player* = object
    kills*, deaths*: int
    name*: Name
    shape*: Polygon

  Projectile* = object
    owner*: Name
    shape*: Polygon

  Map* = seq[Polygon]

  GameState* = object
    projectiles*: seq[Projectile]
    players*: seq[Player]
    map*: Map


# Controls
type
  Action* = enum
    forward = "forward",
    backward = "backward",
    clockwise = "clockwise",
    counterclockwise = "counterclockwise",
    shoot = "shoot",
    join = "join"

  Command* = tuple[name: Name, action: Action]


# Internals
type
  Config* = object
    timemod*: float
    rotationspeed*: float    #  radians/microseconds [-PI;PI]
    movementspeed*: float    #  distance/microseconds
    projectilespeed*: float  #  distance/microseconds

  UpdateInfo* = object
    state*: GameState
    config*: Config
    dt*: int  #  microseconds  
