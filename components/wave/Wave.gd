extends MeshInstance

export var waveYdistortion = 0;
export var waveXdistortion = 0;

var pos = -100;
var glPos = 0.0;
var speed = 8;
var camera;
var wind;
var ship;
var cameraStart;
var windStart;
var shipStart;
var back;
var backStart;
var step = 1.0;
var size = Vector2(0,0)


signal camera_shift(cameraShift, pos, step )


func _ready():
	waveYdistortion = get_surface_material(0).get_shader_param('waveYdistortion');
	waveXdistortion = get_surface_material(0).get_shader_param('waveXdistortion');

	Global.waveYdistortion = waveYdistortion;
	Global.setWaveNoise(get_surface_material(0).get_shader_param('noise_major'));

	camera = get_parent().get_node('Camera');
	wind = get_parent().get_node('StarWind');
	back = get_parent().get_node('Back');

	windStart = wind.transform.origin;
	backStart = back.transform.origin;
	cameraStart = camera.transform.origin;

	size = Vector2(get_mesh().get_subdivide_width() + 1, get_mesh().get_subdivide_depth() + 1);
	get_surface_material(0).set_shader_param('size', size);

	var stepV = (size - Vector2(1,1))/ size
	step = stepV.y



func _physics_process(_delta):
	var cameraShift = Vector3(0, -sin((pos - 1)/10), fmod(pos, step));

	camera.transform.origin = cameraStart - cameraShift;
	wind.transform.origin = windStart - cameraShift;
	# ship.transform.origin = shipStart - cameraShift;
	back.transform.origin = backStart - cameraShift;

	get_surface_material(0).set_shader_param('pos', floor(pos / step));
	get_surface_material(0).set_shader_param('waveYdistortion', waveYdistortion);
	get_surface_material(0).set_shader_param('waveXdistortion', waveXdistortion);

	pos = get_parent().getCoords().y

	emit_signal("camera_shift", cameraShift, pos, step);