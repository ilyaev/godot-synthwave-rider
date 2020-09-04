extends MeshInstance

var t;
var light;
var velocity;
var pos;

func _ready():
	# light = get_parent().get_node('Light').tra
	randomize();
	t = 0;
	velocity = Vector3(0,0,0);
	pos = Vector3(0,0,0);
	get_surface_material(0).set_shader_param("noiseSeed", rand_range(1,2000));



func _process(delta):
	t += delta;
	get_surface_material(0).set_shader_param("t", t);
	get_surface_material(0).set_shader_param("velocity", velocity.y);
	get_surface_material(0).set_shader_param("shipShift", pos.x);

func setShipVelocity(v):
	velocity = v;

func setShipPosition(v):
	pos = v;
