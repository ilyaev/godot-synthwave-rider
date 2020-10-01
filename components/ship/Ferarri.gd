extends Spatial


export var pos = 0
var car
var speed = Vector3(0,0,0)
var front
var back


func _ready():
	car = $Car;
	front = car.get_node('FrontWheels')
	back = car.get_node('BackWheels')



func _process(_delta):
	front.rotation = Vector3(pos, -5.3 * speed.x, 0)
	back.rotation = Vector3(pos, 0, 0)
	pass
