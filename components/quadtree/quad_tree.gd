extends Reference
class_name QuadTree

var capacity = 8
var boundaries: Rect2 = Rect2()
var subdivided: bool = false

var points: Array = []
var quads: Array = []

var values = {}

func _init(brect: Rect2):
    values = {}
    boundaries = brect
    pass


func getPayload(point: Vector2):
    var k = String(point.x) + 'x' + String(point.y);
    return values[k]

func query(region: Rect2):
    var result: Array = []
    if !boundaries.intersects(region, true):
        return result
    for point in points:
        if region.has_point(point):
            result.append(getPayload(point))
    for quad in quads:
        for payload in quad.query(region):
            result.append(payload)
    return result

func insert(point: Vector2, payload):
    if !boundaries.has_point(point):
        return
    if points.size() < capacity:
        var k = String(point.x) + 'x' + String(point.y);
        values[k] = payload
        points.append(point)
        return
    if !subdivided:
        subdivide()
    for quad in quads:
        quad.insert(point, payload)

func subdivide():
    var w = boundaries.size.x / 2
    var h = boundaries.size.y / 2
    var center = boundaries.position + Vector2(w,h)
    var nw = Rect2(center.x - w, center.y - h, w, h)
    var ne = Rect2(center.x, center.y - h, w, h)
    var se = Rect2(center.x, center.y, w, h)
    var sw = Rect2(center.x - w, center.y, w, h)
    quads = [
        get_script().new(nw),
        get_script().new(ne),
        get_script().new(se),
        get_script().new(sw)
    ]
    subdivided = true