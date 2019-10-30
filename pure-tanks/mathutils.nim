# std lib
import math

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


func move*(rect: Rect, distance: float): Rect =
  ## Returns the Rect obtained by moving `distance` in direction `rect.angle`
  return Rect(
    pos: Point(
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

  func intersection(sega, segb: Segment): Option[Point]
    ## Get Point of intersection, between two segments 
    ## Returns None if no interaction was found
    
    # Solution to intersection between two line segments
    # http://www.cs.swan.ac.uk/~cssimon/line_intersection.html
    let ascal = ((segb.a.y - segb.b.y) * (sega.a.x - segb.a.x) +
                 (segb.b.x - segb.a.x) * (sega.a.y - segb.a.y)) /
                ((segb.b.x - segb.a.x) * (sega.a.y - sega.b.y) -
                 (sega.a.x - sega.b.x) * (segb.b.y - segb.a.y))
    let bscal = ((sega.a.y - sega.b.y) * (sega.a.x - segb.a.x) +
                 (sega.b.x - sega.a.x) * (sega.a.y - segb.a.y)) /
                ((segb.b.x - segb.a.x) * (sega.a.y - sega.b.y) -
                 (sega.a.x - sega.b.x) * (segb.b.y - segb.a.y))

    # Check if solution is within the bound of the line segment
    if 0 <= ascal <= 1 and 0 <= bscal <= 1:
      # Multiply line segment by scalar to get the point of intersection.
      # Doesn't matter if use `sega` or `segb`, as the intersection point
      # is the exact same.
      return Some(Point(
        x: (sega.b.x - sega.a.x) * ascal,
        y: (sega.b.y - sega.a.y) * ascal
      ))
    else:
      return None

