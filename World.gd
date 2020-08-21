extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shipPosition = Vector3(0.0,0.0,0.0);
var speed = 5.0;



# Called when the node enters the scene tree for the first time.
func _ready():
	syncShipPosition()
	pass # Replace with function body.

func syncShipPosition():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shipPosition.z += delta * speed;
	syncShipPosition();
	pass
