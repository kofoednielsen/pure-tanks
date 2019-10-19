
type
  Angle = float
  Position = array[2, int]
  Name = string

  Player* = object
    angle: Angle
    pos: Position
    kills, deaths: int
    name*: Name

  Projectile* = object
    angle: Angle
    pos: Position
    owner*: Name

  Rect* = object
    pos: Position
    width, height: int

  Map = seq[Rect]

  GameState* = object
    projectiles*: seq[Projectile]
    players*: seq[Player]
    map: Map

  Action = enum
    forward,
    backward,
    right,
    left,
    shoot,
    join

  Command = tuple[name: Name, action: Action]

  Config* = object
    timemod: float
    playerspeed: float
    projectilespeed: float
