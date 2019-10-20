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
  return arctan2(sin(angle), cos(angle))
