extends MeshInstance

var t;
var light;

func _ready():
	# light = get_parent().get_node('Light').tra
	t = 0;


func _process(delta):
	t += delta;
	get_surface_material(0).set_shader_param("t", t);
