import unittest, strutils, math
import vector


proc `=~` *(x, y: float): bool =
  ## Define `=~` operator for approximate float comparisions
  const eps = 1.0e-7
  result = abs(x - y) < eps


suite "wrap_angle tests":


  test "test 2 PI wraps to 0 PI":
    check(wrap_angle(2 * PI) =~ 0)


  test "test 7 PI/4 wraps to -PI/4":
    check(wrap_angle(7 * PI/4) =~ -PI/4)


  test "test -7 PI/4 wraps to PI/4":
    check(wrap_angle(-7 * PI/4) =~ PI/4)
