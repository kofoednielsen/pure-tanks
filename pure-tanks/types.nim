type
  Angle* = float  #  radians
  Position* = array[2, float]
  Name* = string

  Player* = object
    angle*: Angle
    position*: Position
    kills*, deaths*: int
    name*: Name

  Projectile* = object
    angle*: Angle
    position*: Position
    owner*: Name

  Rect* = object
    position*: Position
    width, height: int

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
