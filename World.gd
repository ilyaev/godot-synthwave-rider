extends Spatial

var velocityFlags = Vector3(0,0,0)
var velocity = Vector3(0,0,0)
var coords = Vector3(0,0,0)
var ship
var maxSpeed = 50
var camera

func _ready():
	ship = $Ship
	camera = $Camera
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
	ship.transform.origin.x = coords.x
	ship.transform.origin.y = 1 - sin((coords.y - 2) / 10)*.1

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