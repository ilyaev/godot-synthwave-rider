extends Node

var current_scene = null

var waveYdistortion = 10

func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)


func getDistortionY(pos, shift, extra):
    return sin((shift - pos) / waveYdistortion) + extra