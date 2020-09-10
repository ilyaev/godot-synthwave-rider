extends MeshInstance

export var roadShift = 0
export var id = 0
export var maxSpeed = .8;

var velocity = Vector3(0,0,0)
var speed = Vector3(0,0,0)
var position = Vector3(0,0,0);
var gravityForce = Vector3(0, 0, -1);
var frictionForce = .2;

# var velocityFlags = Vector3(0,0,0)

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

	speed = speed + velocity * delta;
	if abs(speed.y) > 0:
		speed.y -= frictionForce * sign(speed.y) * delta;
	speed.y = max(-maxSpeed, min(maxSpeed, speed.y));

	position += speed;

	transform.origin.x = position.x
	transform.origin.y = Global.getDistortionY(position.y, roadShift, 0.2);

	var l = 0.25
	var ta = (Global.getDistortionY(position.y + l, roadShift, 0.2) - transform.origin.y) / l;
	rotation = Vector3(atan(ta), -0.1 * sign(speed.x), 0)

	if id != 0:
		position.x = abs(sin(id + t/2)*1.6) + .3;
		if velocity.y < 0:
			position.x *= -1;

	if id != 0:
		transform.origin.z = roadShift - position.y

# func _process(delta):
# 	t += delta;
# 	velocity.y = max(-maxSpeed, min(maxSpeed, velocityFlags.y + velocity.y))
# 	velocity.x = velocityFlags.x

# 	if sheepVerticalPosition < 5:
# 		velocity.z += velocityFlags.z*delta*jForce;
# 	if sheepVerticalPosition > 0:
# 		velocity.z += gForce*delta;

# 	if velocity.z > 0.2:
# 		velocityFlags.z = 0;


# 	if velocity.y > 0:
# 		velocity.y = max(0, velocity.y - .2)

# 	if velocity.y < 0:
# 		velocity.y = min(0, velocity.y + .2)

# 	position += velocity * delta

# 	if id != 0:
# 		position.x = abs(sin(t + id)*1.6) + .3;
# 		if velocityFlags.y < 0:
# 			position.x *= -1;

# 	transform.origin.x = position.x
# 	transform.origin.y = Global.getDistortionY(position.y, roadShift, 0.2);

# 	var l = 0.25
# 	var ta = (Global.getDistortionY(position.y + l, roadShift, 0.2) - transform.origin.y) / l;
# 	rotation = Vector3(atan(ta), -0.1 * sign(velocity.x), 0)

# 	sheepVerticalPosition = min(5, max(0, sheepVerticalPosition + velocity.z));
# 	transform.origin.y += min(5, max(0, sheepVerticalPosition));

# 	if sheepVerticalPosition == 0:
# 		velocity.z = 0;


# 	if id != 0:
# 		transform.origin.z = roadShift - position.y

# 	pass
