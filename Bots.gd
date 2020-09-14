extends Spatial

export var MAX_BOTS = 30;
var camera;
var ship;
var noise = OpenSimplexNoise.new()
var t = 0;
var AVOID_RADIUS = Vector2(0.7, 5.5);

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
		bot.velocity.y = abs(n*1.5 + .3*sign(n));
		bot.id = id + 1
		bot.roadShift = 0;
		bot.position.y = -id*2;

		bot.position.x = .4 * sign(n) + n*2.3;
		bot.originalX = bot.position.x;

		if bot.velocity.y < 0:
			bot.roadShift -= 20;

		add_child(bot)


func isBotNear(src, bot):
	var xd = abs(bot.position.x - src.position.x)
	var yd = abs((bot.position.y - bot.roadShift) - src.position.y)
	# print([(bot.position.y - bot.roadShift), src.position.y])
	if xd < AVOID_RADIUS.x && yd < AVOID_RADIUS.y:
		return bot;
	return false

func getAround(rad, src):
	var result = []

	for bot in get_children():
		if bot.id != src.id && isBotNear(src, bot):
			result.append(bot)


	# print([src.position.y, src.roadShift, ship.position.y - ship.roadShift])
	if isBotNear(src, ship):
		# print('APPEND!')
		result.append(ship);

	return result;

func getAvoidVector(src):
	var items = getAround(AVOID_RADIUS, src);
	var result = Vector2(0, 0);

	if items.size() == 0:
		return result;

	var xc = 0;
	var yc = 0;
	for bot in items:
		var xd = abs(bot.position.x - src.position.x)
		var yd = abs((bot.position.y - bot.roadShift) - src.position.y)
		if xd < AVOID_RADIUS.x && yd < AVOID_RADIUS.y:
			# print('AVOIDXY: ', [src.id, bot.id, xd, yd])
			result.x += src.position.x - bot.position.x
			result.y += (src.position.y - bot.position.y) * (1.0 - yd/AVOID_RADIUS.y) * 0.2;
			yc += 1;
			xc += 1;
		# if yd < AVOID_RADIUS.y && xd :
		# 	result.y += src.position.y - bot.position.y
		# 	yc += 1;

	if xc > 0:
		result.x /= xc;
	if yc > 0:
		result.y /= yc;

	result.x += (src.originalX - src.position.x) * .1;
	# result.x += (0 - src.position.x) * 0.02;

	return result


func _process(delta):
	t += delta
	var cameraOffset = ship.position.y;

	for bot in get_children():
		var dif = abs(bot.position.y - cameraOffset)

		var avoidVector = getAvoidVector(bot)

		bot.velocity.x = avoidVector.x * .7;
		var speedY = avoidVector.y * (bot.speed.y/bot.maxSpeed) * .01;
		bot.speed.y += speedY;
		if bot.speed.y > bot.maxSpeed:
			bot.maxSpeed += speedY
		if avoidVector.x == 0:
			bot.speed.x = max(0, bot.speed.x - 0.01);

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

