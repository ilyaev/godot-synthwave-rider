extends Spatial

var velocityFlags = Vector3(0,0,0)
var velocity = Vector3(0,0,0)
var coords = Vector3(0,0,0)
var ship
var maxSpeed = 50
var camera
var wind
var back
var waveYdistortion

func _ready():
	ship = $Ship
	camera = $Camera
	wind = $StarWind
	back = $Back
	pass

func syncShipPosition():
	pass

func _process(delta):
	velocity.y = max(-maxSpeed, min(maxSpeed, velocityFlags.y + velocity.y))
	velocity.x = velocityFlags.x

	if velocity.y > 0:
		velocity.y = max(0, velocity.y - .2)

	if velocity.y < 0:
		velocity.y = min(0, velocity.y + .2)

	coords += velocity * delta

	waveYdistortion = $Wave.waveYdistortion

	ship.transform.origin.x = coords.x
	ship.transform.origin.y = getDistortionY(coords.y, 17, 0.2);
	camera.transform.origin.y = getDistortionY(coords.y, 21, 2.5);
	wind.transform.origin.y = camera.transform.origin.y + 9.5;

	var l = 0.25
	var ta = (getDistortionY(coords.y + l, 17, 0.2) - ship.transform.origin.y) / l;
	ship.rotation = Vector3(atan(ta), -0.1 * sign(velocity.x), 0)

func getDistortionY(pos, shift, extra):
	return sin((shift - pos) / waveYdistortion) +extra

func getCoords():
	return coords


func _input(event):
	if event.is_action_pressed("ui_left"):
		velocityFlags.x = -1
	if event.is_action_pressed("ui_right"):
		velocityFlags.x = 1
	if event.is_action_pressed("ui_up"):
		velocityFlags.y = 1
	if event.is_action_pressed("ui_down"):
		velocityFlags.y -= 1
	if event.is_action_released("ui_left"):
		velocityFlags.x = 0
	if event.is_action_released("ui_right"):
		velocityFlags.x = 0
	if event.is_action_released("ui_up"):
		velocityFlags.y = 0
	if event.is_action_released("ui_down"):
		velocityFlags.y = 0