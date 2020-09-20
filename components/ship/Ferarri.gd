extends Spatial


export var pos = 0
var car


func _ready():
	car = $Car;



func _process(_delta):
	car.get_node('FrontWheels').rotation = Vector3(pos, 0, 0)
	car.get_node('BackWheels').rotation = Vector3(pos, 0, 0)
	pass
