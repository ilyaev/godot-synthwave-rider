extends MeshInstance

export var roadShift = 0
export var id = 0
export var maxSpeed = .4;
export var originalMaxSpeed = 1;


var xRange = 1.2;
var velocity = Vector3(0,0,0)
var speed = Vector3(0,0,0)
var position = Vector3(xRange,0,0);
var gravityForce = Vector3(0, 0, -1.9);
var frictionForce = .2;
var originalX = 0;
var manevrity = 1;


var model;

var gForce = -1;
var jForce = 2;
var sheepVerticalPosition = 0;

var t = 0;

func _ready():
	transform.origin.z = roadShift;
	model = $Ferarri;

func adjustCamera(shift, _step, globalShift):
	transform.origin.z = roadShift - shift + globalShift;

func _physics_process(delta):

	t += delta;

	speed = speed + (velocity + gravityForce) * delta;

	if abs(speed.y) > 0:
		speed.y -= frictionForce * sign(speed.y) * delta;

	speed.y = max(-maxSpeed, min(maxSpeed, speed.y));

	position += speed;

	position.x = min(xRange, max(-xRange, position.x))

	if abs(position.x) >= xRange:
		velocity.x = 0;
		speed.x = 0;

	transform.origin.x = position.x
	Global.debug = true
	transform.origin.y = Global.getDistortionY(position.y, roadShift, 0.2);
	Global.debug = false

	var l = 0.5;
	var ta = (Global.getDistortionY(position.y + l, roadShift, 0.2) - transform.origin.y) / l;
	rotation = Vector3(atan(ta), (-0.1*(xRange - abs(position.x))) * sign(speed.x), 0); # sin(t*3*sign(speed.x))*.2)
	transform.origin.y -= atan(ta) * 2;

	position.z = min(5, max(0, position.z))
	transform.origin.y += position.z

	if id != 0:
		transform.origin.z = roadShift - position.y

	model.pos = position.y*.314;
	model.speed = speed;
