# std lib
import math
import sugar
import sequtils

# app imports
import types


func `=~` *(a, b: float): bool =
  ## Define `=~` operator for approximate float comparisions
  const eps = 1.0e-7
  return abs(a - b) < eps


func `=~` *(a: Point, b: Point): bool =
  ## Define `=~` operator for approximate point comparisions
  return (a.x =~ b.x) and (a.y =~ b.y)


func point_at_scalar*(seg: Segment, scalar: float): Point =
  ## Get the Point at `scalar` on the Segment
  return Point(
    x: (seg.b.x - seg.a.x) * scalar,
    y: (seg.b.y - seg.a.y) * scalar
  )

func move*(p: Point, angle: Angle, distance: float): Point =
  ## The Point obtained by moving `distance` in direction `angle`
  Point(
    x: p.x + (distance * cos(angle)),
    y: p.y + (distance * sin(angle))
  )

func move*(poly: Polygon, distance: float): Polygon =
  ## The Polygon obtained by moving `distance` in  `poly.angle`

  # function to use on Points for this move
  let thismove = proc(p: Point): Point = move(p, poly.angle, distance)

  # move all the stuff
  let newcenter = thismove(poly.center)
  let newsegments = map(poly.segments,
                        seg => Segment(a: thismove(seg.a),
                                       b: thismove(seg.b)))
  return Polygon(
    center: newcenter,
    angle: poly.angle,
    segments: newsegments
  )

func wrap_angle*(angle: Angle): Angle =
  ## Wraps an angle to fit in range [-PI;PI]
  return arctan2(sin(angle), cos(angle))


func rotate*(poly: Polygon, angledelta: float): Polygon =
  ## Rotates a Rect by `angledelta` radians
  let newangle = poly.angle + angledelta

  # wrap angle into range [-PI;PI]
  let wrappedangle = wrap_angle(newangle)
  assert((-1 * PI) <= wrappedangle and wrappedangle <= PI,
         "Got angle outside range [-PI;PI]")

  return Polygon(
    angle: wrappedangle,
    center: poly.center,
    segments: poly.segments
  )
