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

	# camera.environment.background_sky.sun_longitude = sin(t/10)*50;
	# camera.environment.background_sky.sun_latitude = cos(t/10)*50;

	$Light.transform.origin.y = 10; #sin(t*2)*20;
	# $Light.rotate_x(delta);
	# $Light.rotate_y(delta);
	# $Light.rotate_z(delta*4);


	# camera.transform.origin.y = 10;
	camera.transform.origin.y = Global.getDistortionY(ship.position.y, 21, 2.5);
	back.transform.origin.y = Global.getDistortionY(ship.position.y, 21, 8);
	wind.transform.origin.y = camera.transform.origin.y + 9.5;

	back.setShipVelocity(ship.speed * 50)
	back.setShipPosition(ship.position)


func getCoords():
	return ship.position


func _input(event):
	if event.is_action_pressed("ui_left"):
		ship.speed.x = -.02;
	if event.is_action_pressed("ui_right"):
		ship.speed.x = .02;
	if event.is_action_pressed("ui_up"):
		ship.velocity.y = .5
	if event.is_action_pressed("ui_down"):
		ship.velocity.y = -.5
	if event.is_action_released("ui_left"):
		ship.speed.x = 0
	if event.is_action_released("ui_right"):
		ship.speed.x = 0
	if event.is_action_released("ui_up"):
		ship.velocity.y = 0
	if event.is_action_released("ui_down"):
		ship.velocity.y = 0
	if event.is_action_pressed("ui_accept"):
		ship.speed.z = .3
	if event.is_action_released("ui_accept"):
		ship.speed.z = 0
	if event.is_action_pressed("ui_focus_next"):
		back.visible = !back.visible
