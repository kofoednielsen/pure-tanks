import boxy, opengl, vmath, windy
import types, game, mathutils
import sequtils
import sugar
from strformat import fmt


let hundredsquare = types.Polygon(
  angle: Angle(0),
  center: Point(x: 100, y: 100),
  segments: @[
    types.Segment(a: Point(x: 50, y: 50),    # (50, 50)    (150, 50)
            b: Point(x: 150, y: 50)),  #      +---------+
    types.Segment(a: Point(x: 150, y: 50),   #      |         |
            b: Point(x: 150, y: 150)), #      |  (100,  |
    types.Segment(a: Point(x: 150, y: 150),  #      |   100)  |
            b: Point(x: 50, y: 150)),  #      |         |
    types.Segment(a: Point(x: 50, y: 150),   #      +---------+
            b: Point(x: 50, y: 50))    # (50, 150)   (150, 150)
  ]
)
let john = Player(
  name: Name("John"),
  shape: hundredsquare,
  kills: 3,
  deaths: 1
)

# 100x100 square, centered at (300, 100)
# (leftmost points are x=250, y=50..150)
let johnblockersquare = types.Polygon(
  angle: Angle(0),
  center: Point(x: 200, y: 150),
  segments: @[
    types.Segment(a: Point(x: 250, y: 100),  # (250, 100)   (350, 100)
            b: Point(x: 350, y: 100)), #      +---------+
    types.Segment(a: Point(x: 350, y: 100),  #      |         |
            b: Point(x: 350, y: 200)), #      |  (200,  |
    types.Segment(a: Point(x: 350, y: 200),  #      |   150)  |
            b: Point(x: 250, y: 200)), #      |         |
    types.Segment(a: Point(x: 250, y: 200),  #      +---------+
            b: Point(x: 250, y: 100))  # (250, 200)   (350, 200)
  ]
)
let johnblocker = Player(
  name: Name("JohnBlocker"),
  shape: johnblockersquare,
  kills: 1337,
  deaths: 0
)

# a totally flat and very small wall
# designed for peter to run into
let peterblockersquare = types.Polygon(
  angle: Angle(0),
  center: Point(x: 200, y: 150),
  segments: @[
    types.Segment(a: Point(x: 0, y: 20),
            b: Point(x: 0, y: 40))
  ]
)
let peterblocker = Player(
  name: Name("PeterBlocker"),
  shape: peterblockersquare,
  kills: 5318008,
  deaths: 0
)

var state = GameState(
  projectiles: @[],
  players: @[john, johnblocker, peterblocker],
  map: Map(@[])
)

let config = Config(
  timemod: 1,
  movementspeed: 2,
  rotationspeed: PI/50,
  projectilespeed: 1.5,
  collisionpointdist: 1
)



let window = newWindow("Windy + Boxy", ivec2(1280, 800))
makeContextCurrent(window)
loadExtensions()

let bxy = newBoxy()

var input: Button

var frame: int = 1

# Called when it is time to draw a new frame.
proc display() =
  # Clear the screen and begin a new frame.
  bxy.beginFrame(window.size)

  # Draw the bg.
  bxy.drawRect(rect(vec2(0, 0), window.size.vec2), color(0, 0, 0, 1))

  bxy.saveTransform()

  let image = newImage(500, 500)

  var line = 0
  proc myDrawLine(seg: types.Segment) =
    let ctx = newContext(image)
    ctx.strokeStyle = "#FF5C00"
    ctx.lineWidth = 2

    let
      start = vec2(seg.a.x, seg.a.y)
      stop = vec2(seg.b.x, seg.b.y)

    ctx.strokeSegment(segment(start, stop))
    bxy.addImage(fmt"{line}", image)
    bxy.drawImage(fmt"{line}", center = window.size.vec2 / 2, angle = 0)
    line = line + 1

  

  var commands: seq[Command]
  if input == Button.KeyUp:
    commands = @[
      Command((name: Name("John"), action: forward))
    ]
  if input == Button.KeyDown:
    commands = @[
      Command((name: Name("John"), action: backward))
    ]
  if input == Button.KeyRight:
    commands = @[
      Command((name: Name("John"), action: counterclockwise))
    ]
  if input == Button.KeyLeft:
    commands = @[
      Command((name: Name("John"), action: clockwise))
    ]

  state = update(state, config, 1, commands)

  apply(state.players, (p: Player) => apply(p.shape.segments, myDrawLine))

  bxy.restoreTransform()
  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()
  inc frame

window.onButtonPress = proc(button: Button) =
  input = button

while not window.closeRequested:
  display()
  pollEvents()
