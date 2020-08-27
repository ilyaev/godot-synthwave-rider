extends MeshInstance

var pos = 0;
var glPos = 0.0;
var speed = 8;
var camera;
var cameraStart = Vector3(0,2,22);
var step = 1.0;
var size = Vector2(0,0)


func _ready():
	camera = get_parent().get_node('Camera');
	size = Vector2(get_mesh().get_subdivide_width() + 1, get_mesh().get_subdivide_depth() + 1);
	get_surface_material(0).set_shader_param('size', size);
	var stepV = (size - Vector2(1,1))/ size
	step = stepV.y


func _physics_process(delta):
	var shift = speed * delta;
	camera.transform.origin = cameraStart - Vector3(0, 0, fmod(pos, step));
	get_surface_material(0).set_shader_param('pos', floor(pos / step));
	pos += shift
	# camera.rotate_z(sin(pos) * .01)
	# camera.rotate_x(cos(pos) * .01).
	# camera.rotate_y(sin(pos/2) * .01)

