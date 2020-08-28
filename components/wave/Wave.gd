extends MeshInstance

export var waveYdistortion = 15;
export var waveXdistortion = 0;

var pos = 0;
var glPos = 0.0;
var speed = 8;
var camera;
var wind;
var ship;
var cameraStart = Vector3(0,3,22);
var windStart;
var shipStart;
var back;
var backStart;
var step = 1.0;
var size = Vector2(0,0)
var rotA = 0;
var rot = -PI/4;


func _ready():
	camera = get_parent().get_node('Camera');
	wind = get_parent().get_node('StarWind');
	windStart = wind.transform.origin;
	ship = get_parent().get_node('Ship');
	shipStart = ship.transform.origin;
	back = get_parent().get_node('Back');
	backStart = back.transform.origin;
	size = Vector2(get_mesh().get_subdivide_width() + 1, get_mesh().get_subdivide_depth() + 1);
	get_surface_material(0).set_shader_param('size', size);
	var stepV = (size - Vector2(1,1))/ size
	step = stepV.y


func _physics_process(delta):
	rotA += sign(rot) * PI * delta / 200;
	if sign(rot) != sign(rot - rotA):
		rot = 0
		rotA = 0
	else:
		rot -= rotA;

	var cameraShift = Vector3(0, -sin((pos - 1)/10), fmod(pos, step));

	camera.transform.origin = cameraStart - cameraShift;
	wind.transform.origin = windStart - cameraShift;
	ship.transform.origin = shipStart - cameraShift;
	back.transform.origin = backStart - cameraShift;

	get_surface_material(0).set_shader_param('pos', floor(pos / step));
	get_surface_material(0).set_shader_param('waveYdistortion', waveYdistortion);
	get_surface_material(0).set_shader_param('waveXdistortion', waveXdistortion);

	pos = get_parent().getCoords().y


