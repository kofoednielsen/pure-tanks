# std lib
import math

# app imports
import types

func move*(position: Position, angle: Angle, distance: float): Position =
  ## Returns the Position obtained by moving `distance` in direction `angle`
  return Position([
    position[0] + (distance * cos(angle)),
    position[1] + (distance * sin(angle))
  ])


func wrap_angle*(angle: Angle): Angle =
  ## Wraps an angle to fit in range [-PI;PI]
  if angle < (-1 * PI):
    return wrap_angle(angle + (2 * PI))
  elif angle > PI:
    return wrap_angle(angle - (2 * PI))
  else:
    return angle
