extends MeshInstance

export var roadShift = 0
export var id = 0
export var maxSpeed = 1;

var velocity = Vector3(0,0,0)
var speed = Vector3(0,0,0)
var position = Vector3(0,0,0);
var gravityForce = Vector3(0, 0, -.9);
var frictionForce = .2;
var originalX = 0;

var gForce = -1;
var jForce = 2;
var sheepVerticalPosition = 0;

var t = 0;

func _ready():
	transform.origin.z = roadShift;

func adjustCamera(shift, _step, globalShift):
	transform.origin.z = roadShift - shift + globalShift;

func _physics_process(delta):
	t += delta;

	speed = speed + (velocity + gravityForce) * delta;

	if abs(speed.y) > 0:
		speed.y -= frictionForce * sign(speed.y) * delta;

	speed.y = max(-maxSpeed, min(maxSpeed, speed.y));

	position += speed;

	transform.origin.x = position.x
	# var b = transform.origin.y;
	Global.debug = true
	transform.origin.y = Global.getDistortionY(position.y, roadShift, 0.2);
	Global.debug = false
	# print([position.y, transform.origin.y, transform.origin.y - b])

	var l = 0.5;
	var ta = (Global.getDistortionY(position.y + l, roadShift, 0.2) - transform.origin.y) / l;
	rotation = Vector3(atan(ta), -0.1 * sign(speed.x), 0)
	transform.origin.y -= atan(ta) * 2;

	position.z = min(5, max(0, position.z))
	transform.origin.y += position.z

	# if id != 0:
	# 	position.x = abs(sin(id + t/2)*1.6) + .3;
	# 	if velocity.y < 0:
	# 		position.x *= -1;

	if id != 0:
		transform.origin.z = roadShift - position.y

	originalX = sin(t*0.01 + id/10)*.2;