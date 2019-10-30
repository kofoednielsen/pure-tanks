type
  Angle* = float  #  radians
  Name* = string

  Point* = object
    x*, y*: float

  Segment* = object
    a*, b*: Point

  Rect* = object
    angle*: Angle
    pos*: Point
    width*, height*: int

  Player* = object
    kills*, deaths*: int
    name*: Name
    shape*: Rect

  Projectile* = object
    owner*: Name
    shape*: Rect

  Map* = seq[Rect]

  GameState* = object
    projectiles*: seq[Projectile]
    players*: seq[Player]
    map*: Map

  Action* = enum
    forward = "forward",
    backward = "backward",
    clockwise = "clockwise",
    counterclockwise = "counterclockwise",
    shoot = "shoot",
    join = "join"

  Command* = tuple[name: Name, action: Action]

  Config* = object
    timemod*: float
    rotationspeed*: float    #  radians/microseconds [-PI;PI]
    movementspeed*: float    #  distance/microseconds
    projectilespeed*: float  #  distance/microseconds

  UpdateInfo* = object
    state*: GameState
    config*: Config
    dt*: int  #  microseconds  
