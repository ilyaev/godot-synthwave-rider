extends Spatial

export var MAX_BOTS = 50;
var camera;
var ship;
var noise = OpenSimplexNoise.new()
var t = 0;
var AVOID_RADIUS = .5;

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

		bot.maxSpeed = rand_range(3, 5) / 10;
		bot.velocity.y = n*1.5 + .3*sign(n);
		bot.id = id + 1
		bot.roadShift = id/1.5;

		bot.position.x = .4 * sign(n) + n*2.3;
		bot.originalX = bot.position.x;

		if bot.velocity.y < 0:
			bot.roadShift -= 20;

		add_child(bot)

func getAround(rad, src):
	var result = []

	for bot in get_children():
		if bot.id != src.id:
			var xd = abs(bot.position.x - src.position.x)
			var yd = abs(bot.position.y - src.position.y)
			if xd < rad && yd < rad:
				result.append(bot)


	if (abs(ship.position.x - src.position.x) < rad) && (abs(ship.position.y - src.position.y) < rad):
		# print('APPEND SHIP')
		result.append(ship)

	# print([ship.position.y, src.position.y])
	return result;

func getAvoidVector(src):
	var items = getAround(AVOID_RADIUS, src);
	var result = Vector2(0, 0);

	if items.size() == 0:
		return result;

	for bot in items:
		result.x += src.position.x - bot.position.x
		result.y += src.position.y - bot.position.y
	result.x /= items.size();
	result.y /= items.size();
	result.x += (src.originalX - src.position.x) * 0.5;
	return result


func _process(delta):
	t += delta
	var cameraOffset = ship.position.y;

	for bot in get_children():
		var dif = abs(bot.position.y - cameraOffset)

		var avoidVector = getAvoidVector(bot)
		bot.velocity.x = avoidVector.x * .7;
		bot.speed.y += avoidVector.y * .15;
		if avoidVector.x == 0:
			bot.speed.x = max(0, bot.speed.x - 0.01);
		# else:
		# 	bot.speed.z = .1;
		# if avoidVector != 0:
		# 	print(bot.id, ' - ', avoidVector);


		# if dif > 30:
		# 	bot.visible = false;
		# else:
		# 	bot.visible = true;

		if dif > 100 + ship.id/5:
			bot.maxSpeed = rand_range(5,8) / 10;

			if bot.position.y > cameraOffset:
				bot.position.y = cameraOffset - 25;
			else:
				bot.position.y = cameraOffset + 40;

			# bot.visible = false;
			var n = rand_range(0, 1)*sign(bot.position.x);
			bot.position.x = .4 * sign(n) + n*1.2;
			bot.speed.y /= 3;
			bot.originalX = bot.position.x;

