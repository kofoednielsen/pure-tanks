# std lib
import math

# app imports
import types


func `=~` *(x, y: float): bool =
  ## Define `=~` operator for approximate float comparisions
  const eps = 1.0e-7
  result = abs(x - y) < eps


func move*(rect: Rect, distance: float): Rect =
  ## Returns the Position obtained by moving `distance` in direction `angle`
  return Rect(
    pos: Position(
      x: rect.pos.x + (distance * cos(rect.angle)),
      y: rect.pos.y + (distance * sin(rect.angle))
    ),
    angle: rect.angle,
    width: rect.width,
    height: rect.height
  )


func wrap_angle*(angle: Angle): Angle =
  ## Wraps an angle to fit in range [-PI;PI]
  return arctan2(sin(angle), cos(angle))


func rotate*(rect: Rect, angledelta: float): Rect =
  ## Rotates a Rect by `angledelta` radians
  let newangle = rect.angle + angledelta

  # wrap angle into range [-PI;PI]
  let wrappedangle = wrap_angle(newangle)
  assert((-1 * PI) <= wrappedangle and wrappedangle <= PI,
         "Got angle outside range [-PI;PI]")

  return Rect(
    angle: wrappedangle,
    pos: rect.pos,
    width: rect.width,
    height: rect.height
  )
