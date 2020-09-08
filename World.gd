extends Spatial

var ship
var camera
var wind
var wave
var back
var t = 0

func _ready():
	ship = $Ship
	camera = $Camera
	wind = $StarWind
	back = $Back
	wave = $Wave

	Global.waveYdistortion = $Wave.waveYdistortion

	wave.connect("camera_shift", self, "onCameraShift")

	$Bots.setup();

func onCameraShift(cameraShift, pos, step):
	ship.adjustCamera(cameraShift.z, step, 0)
	$Bots.transform.origin.z = 0 + pos - cameraShift.z;
	$Bots.camera = camera;
	$Bots.ship = ship;

func _process(delta):
	t += delta;

	camera.transform.origin.y = Global.getDistortionY(ship.coords.y, 21, 2.5);
	back.transform.origin.y = Global.getDistortionY(ship.coords.y, 21, 8);
	wind.transform.origin.y = camera.transform.origin.y + 9.5;

	back.setShipVelocity(ship.velocity)
	back.setShipPosition(ship.coords)


func getCoords():
	return ship.coords


func _input(event):
	if event.is_action_pressed("ui_left"):
		ship.velocityFlags.x = -1
	if event.is_action_pressed("ui_right"):
		ship.velocityFlags.x = 1
	if event.is_action_pressed("ui_up"):
		ship.velocityFlags.y = 1
	if event.is_action_pressed("ui_down"):
		ship.velocityFlags.y -= 1
	if event.is_action_released("ui_left"):
		ship.velocityFlags.x = 0
	if event.is_action_released("ui_right"):
		ship.velocityFlags.x = 0
	if event.is_action_released("ui_up"):
		ship.velocityFlags.y = 0
	if event.is_action_released("ui_down"):
		ship.velocityFlags.y = 0
	if event.is_action_pressed("ui_accept"):
		ship.velocityFlags.z = 1
	if event.is_action_released("ui_accept"):
		ship.velocityFlags.z = 0
