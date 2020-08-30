extends MeshInstance

var t;


func _ready():
	t = 0;


func _process(delta):
	t += delta;
	get_surface_material(0).set_shader_param("t", t);
