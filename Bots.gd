extends Spatial

export var MAX_BOTS = 50;
var camera;
var ship;
var noise = OpenSimplexNoise.new()
var t = 0;

var shipScene = preload("res://components/ship/Ship.tscn")

func _ready():
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 10.0
	noise.persistence = 0.8
	noise.lacunarity = 10.0
	pass # Replace with function body.


func setup():
	for id in range(MAX_BOTS):
		var bot = shipScene.instance()
		var n = noise.get_noise_1d(id*10 + 1)
		bot.maxSpeed = rand_range(10,50);
		bot.velocityFlags.y = n*1.5 + .3*sign(n);
		bot.id = id + 1
		bot.position = id/1.5;
		if bot.velocityFlags.y < 0:
			bot.position -= 20;
		# bot.get_surface_material(0).set_shader_param("color", Vector3(n*3, sin(n + id), cos(n)));
		add_child(bot)

func _process(delta):
	t += delta
	for bot in get_children():
		var dif = abs(bot.coords.y - ship.coords.y)

		if dif > 30:
			bot.visible = false;
		else:
			bot.visible = true;

		if dif > 100:
			bot.maxSpeed = rand_range(10,50);

			if bot.coords.y > ship.coords.y:
				bot.coords.y = ship.coords.y - 5;
			else:
				bot.coords.y = ship.coords.y + 40;

			bot.visible = false;
			# bot.velocity.y *= 0.5;

