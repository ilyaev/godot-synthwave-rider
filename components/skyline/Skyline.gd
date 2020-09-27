extends Particles

var t;
var velocity;
var pos;

func _ready():
	randomize();
	t = 0;
	velocity = Vector3(0,0,0);
	pos = Vector3(0,0,0);
	process_material.set_shader_param("noiseSeed", rand_range(1,2000));



func _process(delta):
	t += delta;
	# get_surface_material(0).set_shader_param("t", t);
	process_material.set_shader_param("velocity", velocity.y);
	process_material.set_shader_param("shipShift", pos.x);

func setShipVelocity(v):
	velocity = v;

func setShipPosition(v):
	pos = v;

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
