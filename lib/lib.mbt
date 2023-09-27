type Canvas_ctx

func set_stroke_color(self : Canvas_ctx, color : Int) = "canvas" "set_stroke_color"

func move_to(self : Canvas_ctx, x : Int, y : Int) = "canvas" "move_to"

func line_to(self : Canvas_ctx, x : Int, y : Int) = "canvas" "line_to"

func begin_path(self : Canvas_ctx) = "canvas" "begin_path"

func stroke(self : Canvas_ctx) = "canvas" "stroke"

func fill_rect(self : Canvas_ctx, x : Int, y : Int, width : Int, height : Int) = "canvas" "fill_rect"

func set_fill_style(self : Canvas_ctx, color : Int) = "canvas" "set_fill_style"

func sqrt(x : Float64) -> Float64 = "math" "sqrt"

func ln(x : Float64) -> Float64 = "math" "log"

func pow(x : Float64, y : Float64) -> Float64 = "math" "pow"

func random() -> Float64 = "math" "random"

func sin(x : Float64) -> Float64 = "math" "sin"

func cos(x : Float64) -> Float64 = "math" "cos"

func fabs(x : Float64) -> Float64 = "math" "abs"

let pi : Float64 = 3.141592653589793238462643383279502884197169399375105820974944592307816406286

struct Vec {
  x : Float64
  y : Float64
  z : Float64
}

func vec(x : Float64, y : Float64, z : Float64) -> Vec {
  { x, y, z }
}

let vec_default : Vec = { x: 0.0, y: 0.0, z: 0.0 }

func Vec::default() -> Vec {
  vec_default
}

func op_add(self : Vec, other : Vec) -> Vec {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

func op_sub(self : Vec, other : Vec) -> Vec {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

func op_mul(self : Vec, other : Vec) -> Vec {
  { x: self.x * other.x, y: self.y * other.y, z: self.z * other.z }
}

func scalar_mul(self : Vec, other : Float64) -> Vec {
  { x: self.x * other, y: self.y * other, z: self.z * other }
}

func scalar_mul(self : Float64, other : Vec) -> Vec {
  { x: self * other.x, y: self * other.y, z: self * other.z }
}

func norm(self : Vec) -> Vec {
  self.scalar_mul(1.0 / sqrt(dot(self, self)))
}

func dot(self : Vec, other : Vec) -> Float64 {
  self.x * other.x + self.y * other.y + self.z * other.z
}

func modulo(self : Vec, other : Vec) -> Vec {
  {
    x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x,
  }
}

func draw_pixel(ctx : Canvas_ctx, x : Int, y : Int, color: Vec) {
  let rgb = (to_int(color.x).lsl(16L)).lor(to_int(color.y).lsl(8L)).lor(to_int(color.z)).to_int()
  ctx.set_stroke_color(rgb)
  ctx.fill_rect(x, y, 1, 1)
}

struct Ray {
  origin : Vec
  direction : Vec
}

func ray(origin : Vec, direction : Vec) -> Ray {
  { origin, direction }
}

let ray_default : Ray = { origin: vec_default, direction: vec_default }

func Ray::default() -> Ray {
  ray_default
}

enum Refl {
  DIFF
  SPEC
  REFR
}

func op_equal(self : Refl, other : Refl) -> Bool {
  match (self, other) {
    (DIFF, DIFF) => true
    (SPEC, SPEC) => true
    (REFR, REFR) => true
    _ => false
  }
}

struct Sphere {
  radius : Float64
  position : Vec
  emission : Vec
  color : Vec
  reflection : Refl
}

func sphere(radius : Float64, position : Vec, emission : Vec, color : Vec,
        reflection : Refl) -> Sphere {
  { radius, position, emission, color, reflection }
}

func intersect(self : Sphere, other : Ray) -> Float64 {
  let op = self.position - other.origin
  let eps = 1.e-4
  let b = dot(op, other.direction)
  let det = b * b - dot(op, op) + self.radius * self.radius
  if det < 0.0 {
    return 0.0
  }
  let det_sqrt = sqrt(det)
  let t1 = b - det_sqrt
  if t1 > eps {
    return t1
  }
  let t2 = b + det_sqrt
  if t2 > eps {
    return t2
  }
  return 0.0
}

let spheres : Array[Sphere] = [
  sphere(
    1.0e5,
    vec(1.0e5 + 1.0, 40.8, 81.6),
    Vec::default(),
    vec(0.75, 0.25, 0.25),
    DIFF,
  ),
  sphere(
    1.0e5,
    vec(-1.0e5 + 99.0, 40.8, 81.6),
    Vec::default(),
    vec(0.25, 0.25, 0.75),
    DIFF,
  ),
  sphere(
    1.0e5,
    vec(50.0, 40.8, 1.0e5),
    Vec::default(),
    vec(0.75, 0.75, 0.75),
    DIFF,
  ),
  sphere(
    1.0e5,
    vec(50.0, 40.8, -1.0e5 + 170.0),
    Vec::default(),
    Vec::default(),
    DIFF,
  ),
  sphere(
    1.0e5,
    vec(50.0, 1.0e5, 81.6),
    Vec::default(),
    vec(0.75, 0.75, 0.75),
    DIFF,
  ),
  sphere(
    1.0e5,
    vec(50.0, -1.0e5 + 81.6, 81.6),
    Vec::default(),
    vec(0.75, 0.75, 0.75),
    DIFF,
  ),
  sphere(
    16.5,
    vec(27.0, 16.5, 47.0),
    Vec::default(),
    vec(1.0, 1.0, 1.0).scalar_mul(0.999),
    SPEC,
  ),
  sphere(
    16.5,
    vec(73.0, 16.5, 78.0),
    Vec::default(),
    vec(1.0, 1.0, 1.0).scalar_mul(0.999),
    REFR,
  ),
  sphere(
    600.0,
    vec(50.0, 681.6 - 0.27, 81.6),
    vec(12.0, 12.0, 12.0),
    Vec::default(),
    DIFF,
  ),
]

func clamp(x : Float64) -> Float64 {
  if x < 0.0 {
    return 0.0
  }
  if x > 1.0 {
    return 1.0
  }
  return x
}

func to_int(x : Float64) -> Int64 {
  (pow(clamp(x), 1.0 / 2.2) * 255.0 + 0.5).to_int64()
}

func isIntersectWith(r : Ray, t : Ref[Float64], id : Ref[Int]) -> Bool {
  var i = 0
  let len = spheres.length()
  let inf = 1.e20
  while i < len {
    if i != id.val {
      let d = intersect(spheres[i], r)
      if d < t.val {
        t.val = d
        id.val = i
      }
    }
    i = i + 1
  }
  return t.val < inf
}


func radiance(r : Ray, depth : Ref[Int]) -> Vec {
  let t = { val: 0.0 }
  let id = { val: 0 }
  if not(isIntersectWith(r, t, id)) {
    return Vec::default()
  }
  let obj = spheres[id.val]
  let x = r.origin + r.direction.scalar_mul(t.val)
  let n = norm(x - obj.position)
  let nl = if dot(n, r.direction) < 0.0 {
    n
  } else {
    n.scalar_mul(-1.0)
  }
  var f = obj.color
  let p = if f.x > f.y && f.x > f.z {
    f.x
  } else if f.y > f.z {
    f.y
  } else {
    f.z
  }
  depth.val = depth.val + 1
  if depth.val > 5 {
    if random() < p {
      f = f.scalar_mul(1.0 / p)
    } else {
      return obj.emission
    }
  }
  if obj.reflection == DIFF {
    let r1 = 2.0 * pi * random()
    let r2 = random()
    let r2s = sqrt(r2)
    let w = nl
    let u = modulo(
      if fabs(w.x) > 0.1 { vec(0.0, 1.0, 0.0) } else { vec(1.0, 0.0, 0.0) },
      w,
    ).norm()
    let v = modulo(w, u)
    let d = (u.scalar_mul(cos(r1) * r2s) + v.scalar_mul(sin(r1) * r2s) + w.scalar_mul(
      sqrt(1.0 - r2),
    )).norm()
    return obj.emission + f * radiance(ray(x, d), depth)
  } else if obj.reflection == SPEC {
    return obj.emission + f * radiance(
      ray(x, r.direction - n.scalar_mul(2.0 * dot(n, r.direction))),
      depth,
    )
  }
  let reflRay = ray(x, r.direction - n.scalar_mul(2.0 * dot(n, r.direction)))
  let into = dot(n, nl) > 0.0
  let nc = 1.0
  let nt = 1.5
  let nnt = if into {
    nc / nt
  } else {
    nt / nc
  }
  let ddn = dot(r.direction, nl)
  let cos2t = 1.0 - nnt * nnt * (1.0 - ddn * ddn)
  if cos2t < 0.0 {
    return obj.emission + f * radiance(reflRay, depth)
  }
  let tdir = (r.direction.scalar_mul(nnt) - n.scalar_mul(
    if into {
      1.0
    } else {
      -1.0
    } * (ddn * nnt + sqrt(cos2t)),
  )).norm()
  let a = nt - nc
  let b = nt + nc
  let r0 = a * a / (b * b)
  let c = if into {
    1.0 + ddn
  } else {
    1.0 - dot(tdir, n)
  }
  let re = r0 + (1.0 - r0) * c * c * c * c * c
  let tr = 1.0 - re
  let p = 0.25 + 0.5 * re
  let rp = re / p
  let tp = tr / (1.0 - p)
  obj.emission + f * if depth.val > 2 {
    if random() < p {
      radiance(reflRay, depth).scalar_mul(rp)
    } else {
      radiance(ray(x, tdir), depth).scalar_mul(tp)
    }
  } else {
    radiance(reflRay, depth).scalar_mul(re) + radiance(ray(x, tdir), depth).scalar_mul(
      tr,
    )
  }
}

pub let w = 400
pub let h = 400
pub let c : Array[Vec] = Array::make(w * h, Vec::default())

pub func render(ctx : Canvas_ctx) {
  var y = 0
  while y < h {
    var x = 0
    while x < w {
      let i = (h - y - 1) * w + x
      let color = c[i]
      draw_pixel(ctx, x, y, color)
      x = x + 1
    }
    y = y + 1
  }
}

pub func run() {
  let samps = 1
  let cam = ray(vec(50.0, 52.0, 295.6), vec(0.0, -0.042612, -1.0).norm())
  let cx = vec(w.to_float64() * 0.5135 / h.to_float64(), 0.0, 0.0)
  let cy = modulo(cx, cam.direction).norm().scalar_mul(0.5135)
  var y = 0
  var x = 0
  var sy = 0
  var sx = 0
  var r = vec_default
  var s = 0
  while y < h {
    x = 0
    while x < w {
      sy = 0
      let i = (h - y - 1) * w + x
      while sy < 2 {
        r = vec_default
        sx = 0
        while sx < 2 {
          s = 0
          while (s < samps) {
            let r1 = 2.0 * random()
            let dx = if r1 < 1.0 {
              sqrt(r1) - 1.0
            } else {
              1.0 - sqrt(2.0 - r1)
            }
            let r2 = 2.0 * random()
            let dy = if r2 < 1.0 {
              sqrt(r2) - 1.0
            } else {
              1.0 - sqrt(2.0 - r2)
            }
            let d = cx.scalar_mul(((sx.to_float64() + 0.5 + dx) / 2.0 + x.to_float64()) / w.to_float64() - 0.5) +
                         cy.scalar_mul(((sy.to_float64() + 0.5 + dy) / 2.0 + y.to_float64()) / h.to_float64() - 0.5) +
                         cam.direction
            r = r + radiance(ray(cam.origin + d.scalar_mul(140.0), d.norm()), {val:0}).scalar_mul(1.0 / samps.to_float64())
            s = s + 1
          }
          c[i] = c[i] + vec(clamp(r.x), clamp(r.y), clamp(r.z)).scalar_mul(0.25)
          sx = sx + 1
        }
        sy = sy + 1
      }
      x = x + 1
    }
    y = y + 1
  }
}


pub func online(ctx : Canvas_ctx) {
  let samps = 1
  let cam = ray(vec(50.0, 52.0, 295.6), vec(0.0, -0.042612, -1.0).norm())
  let cx = vec(w.to_float64() * 0.5135 / h.to_float64(), 0.0, 0.0)
  let cy = modulo(cx, cam.direction).norm().scalar_mul(0.5135)
  var y = 0
  var x = 0
  var sy = 0
  var sx = 0
  var r = vec_default
  var s = 0
  var c = vec_default
  while y < h {
    x = 0
    while x < w {
      sy = 0
      while sy < 2 {
        r = vec_default
        sx = 0
        c = vec_default
        while sx < 2 {
          s = 0
          while (s < samps) {
            let r1 = 2.0 * random()
            let dx = if r1 < 1.0 {
              sqrt(r1) - 1.0
            } else {
              1.0 - sqrt(2.0 - r1)
            }
            let r2 = 2.0 * random()
            let dy = if r2 < 1.0 {
              sqrt(r2) - 1.0
            } else {
              1.0 - sqrt(2.0 - r2)
            }
            let d = cx.scalar_mul(((sx.to_float64() + 0.5 + dx) / 2.0 + x.to_float64()) / w.to_float64() - 0.5) +
                         cy.scalar_mul(((sy.to_float64() + 0.5 + dy) / 2.0 + y.to_float64()) / h.to_float64() - 0.5) +
                         cam.direction
            r = r + radiance(ray(cam.origin + d.scalar_mul(140.0), d.norm()), {val:0}).scalar_mul(1.0 / samps.to_float64())
            s = s + 1
          }
          c = c + vec(clamp(r.x), clamp(r.y), clamp(r.z)).scalar_mul(0.25)
          sx = sx + 1
        }
        draw_pixel(ctx, x, y, c)
        sy = sy + 1
      }
      x = x + 1
    }
    y = y + 1
  }
}

