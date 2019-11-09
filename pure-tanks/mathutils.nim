# std lib
import math
import options
import sequtils
import sugar

# app imports
import types


func `=~` *(a, b: float): bool =
  ## Define `=~` operator for approximate float comparisions
  const eps = 1.0e-7
  return abs(a - b) < eps


func `=~` *(a, b: Point): bool =
  ## Define `=~` operator for approximate point comparisions
  (a.x =~ b.x) and (a.y =~ b.y)


func dot*(a, b: Vector): float =
  ## Dot product of two vectors
  (a.x * b.x) + (a.y * b.y)


func `*` (f: float, v: Vector): Vector =
  ## Transform Vector `v` by scalar `f`
  Vector(x: v.x * f,
         y: v.y * f)

func `*` (i: int, v: Vector): Vector = float(i) * v


func len*(v: Vector): float =
  ## Length of a Vector (pythagoras)
  sqrt(v.x^2 + v.y^2)


func len*(seg: Segment): float =
  ## Length of a line Segment (pythagoras)
  sqrt((seg.b.x - seg.a.x)^2 + (seg.b.y - seg.a.y)^2)


func point_at_scalar*(seg: Segment, scalar: float): Point =
  ## Returns the Point at `scalar` along the given Segment
  Point(x: seg.a.x + (seg.b.x - seg.a.x) * scalar,
        y: seg.a.y + (seg.b.y - seg.a.y) * scalar)


func to_vector*(angle: Angle, length: float): Vector =
  ## Angle, distance -> Vector
  Vector(x: cos(angle) * length,
         y: sin(angle) * length)


func translate*(p: Point, v: Vector): Point =
  ## Translate Point `p` by Vector `v`
  Point(x: p.x + v.x, y: p.y + v.y)


func move*(poly: Polygon, distance: float): Polygon =
  ## The Polygon obtained by moving `distance` in  `poly.angle`
  
  # define this movement as a function
  let movementvector = Vector(x: cos(poly.angle) * distance,
                              y: sin(poly.angle) * distance)
  let thismove = func(p: Point): Point = translate(p, movementvector)

  # apply movement to all the stuff
  let newcenter = thismove(poly.center)
  let newsegments = map(poly.segments, seg => Segment(a: thismove(seg.a),
                                                      b: thismove(seg.b)))
  return Polygon(
    center: newcenter,
    segments: newsegments,
    angle: poly.angle
  )


func wrap_angle*(angle: Angle): Angle =
  ## Wraps an angle to fit in range [-PI;PI]
  arctan2(sin(angle), cos(angle))


func rotate*(p: Point, c: Point, delta: Angle): Point =
  ## Rotates a Point around center `c` by `delta` radians
  # shift p so that rotate center is at origin
  # (translate by vector spanning c -> origo)
  let po = translate(p, Vector(x: -c.x, y: -c.y))
  # rotate around origin
  let rotated = Point(
    x: (po.x * cos(delta)) - (po.y * sin(delta)),
    y: (po.y * cos(delta)) - (po.y * sin(delta)),
  )
  # shift back to original placement
  let newp = translate(rotated, Vector(x: c.x, y: c.y))
  return newp


func rotate*(poly: Polygon, delta: Angle): Polygon =
  ## Rotates a Polygon by `delta` radians
  # rotate angle, keeping in range [-PI;PI]
  let newangle = wrap_angle(poly.angle + delta)
  assert((-1 * PI) <= newangle and newangle <= PI,
         "Got angle outside range [-PI;PI]")

  # make function for rotating with delta around center.
  let rotated = func(p: Point): Point = rotate(p, poly.center, delta)
  # rotate all segments
  let newsegments = map(poly.segments, seg => Segment(a: rotated(seg.a),
                                                      b: rotated(seg.b)))
  return Polygon(
    angle: newangle,
    segments: newsegments,
    center: poly.center
  )


func intersection*(sega, segb: Segment): Option[Point] =
  ## Get Point of intersection, between two segments,
  ## returns None if no interaction was found
  
  # solution to intersection between two line segments
  # http://www.cs.swan.ac.uk/~cssimon/line_intersection.html
  let ascal = ((segb.a.y - segb.b.y) * (sega.a.x - segb.a.x) +
               (segb.b.x - segb.a.x) * (sega.a.y - segb.a.y)) /
              ((segb.b.x - segb.a.x) * (sega.a.y - sega.b.y) -
               (sega.a.x - sega.b.x) * (segb.b.y - segb.a.y))
  let bscal = ((sega.a.y - sega.b.y) * (sega.a.x - segb.a.x) +
               (sega.b.x - sega.a.x) * (sega.a.y - segb.a.y)) /
              ((segb.b.x - segb.a.x) * (sega.a.y - sega.b.y) -
               (sega.a.x - sega.b.x) * (segb.b.y - segb.a.y))

  # check if solution is within the bounds of the line segments
  if (0 <= ascal and ascal <= 1) and (0 <= bscal and bscal <= 1):
    # dultiply line segment by scalar to get the point of intersection.
    # doesn't matter if use `sega` or `segb`, as the intersection point
    # is the exact same.
    return some(point_at_scalar(sega, ascal))
  else:
    return none(Point)


func intersection*(arc: CircleArc, seg: Segment): Option[Point] =
  ## Find intersection Point between CircleArc and Segment
  ## https://www.geometrictools.com/Documentation/IntersectionLine2Circle2.pdf
  # delta = seg.a - arc.center
  let Δ = Vector(x: seg.a.x - arc.center.x,
                     y: seg.a.y - arc.center.y)
 
  # D = seg.b - seg.a
  # (vector spanning from start of seg to end of seg)
  let D = Vector(x: seg.b.x - seg.a.x,
                 y: seg.b.y - seg.a.y)

  # 𝛿 used to determine if there is an intersection
  let 𝛿 = dot(D, Δ)^2 - (len(D)^2 * (len(Δ)^2 - arc.radius^2))
  if 𝛿 < 0:  # no intersection
    return none(Point)

  # an intersection!
  # find where on the Segment
  # XXX: this could defintely be optimized
  let tplus = ((-1 * dot(D, Δ)) + sqrt(𝛿)) / len(D)^2
  let tminus = ((-1 * dot(D, Δ)) - sqrt(𝛿)) / len(D)^2

  # filter for values in range [0;1]
  let tvalid = @[tplus, tminus].filter(t => 0 <= t and t <= 1)
  assert(len(tvalid) == 1, "Got `t` outside [0; 1]")

  # get the point and return
  return some(point_at_scalar(seg, tvalid[0]))
