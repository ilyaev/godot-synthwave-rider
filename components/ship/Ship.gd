extends MeshInstance

export var position = 0
export var id = 0

var velocityFlags = Vector3(0,0,0)
var velocity = Vector3(0,0,0)
var coords = Vector3(0,0,0)
var gForce = -1;
var jForce = 2;
var sheepVerticalPosition = 0;
var maxSpeed = 50

func _ready():
	transform.origin.z = position;

func adjustCamera(shift, step, globalShift):
	transform.origin.z = position - shift + globalShift;

func _process(delta):
	velocity.y = max(-maxSpeed, min(maxSpeed, velocityFlags.y + velocity.y))
	velocity.x = velocityFlags.x

	if sheepVerticalPosition < 5:
		velocity.z += velocityFlags.z*delta*jForce;
	if sheepVerticalPosition > 0:
		velocity.z += gForce*delta;

	if velocity.z > 0.2:
		velocityFlags.z = 0;


	if velocity.y > 0:
		velocity.y = max(0, velocity.y - .2)

	if velocity.y < 0:
		velocity.y = min(0, velocity.y + .2)

	coords += velocity * delta

	print(id,': ',coords)

	transform.origin.x = coords.x
	transform.origin.y = Global.getDistortionY(coords.y, position, 0.2);

	var l = 0.25
	var ta = (Global.getDistortionY(coords.y + l, position, 0.2) - transform.origin.y) / l;
	rotation = Vector3(atan(ta), -0.1 * sign(velocity.x), 0)

	sheepVerticalPosition = min(5, max(0, sheepVerticalPosition + velocity.z));
	transform.origin.y += min(5, max(0, sheepVerticalPosition));

	if sheepVerticalPosition == 0:
		velocity.z = 0;


	if id != 0:
		transform.origin.z = position - coords.y

	pass
