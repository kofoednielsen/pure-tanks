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
    angle: rect.angle,
    width: rect.width,
    height: rect.height,
    pos: Position([
      x: rect.pos.x + (distance * cos(angle)),
      y: rect.pos.y + (distance * sin(angle))
    ])
  )


func wrap_angle*(angle: Angle): Angle =
  ## Wraps an angle to fit in range [-PI;PI]
  return arctan2(sin(angle), cos(angle))
