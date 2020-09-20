extends Spatial

const QuadTree = preload('res://components/quadtree/quad_tree.gd')

export var MAX_BOTS = 10;
var camera;
var ship;
var noise = OpenSimplexNoise.new()
var t = 0;
var AVOID_RADIUS = Vector2(1.2, 6.5);
var quadTree: QuadTree
var useQuadTree: bool = true

var shipScene = preload("res://components/ship/Ship.tscn")

func _ready():
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 10.0
	noise.persistence = 0.8
	noise.lacunarity = 10.0
	if MAX_BOTS <= 20:
		useQuadTree = false

func rebuildQuadTree():
	quadTree = null
	var minV = 10000
	var maxV = -10000
	var added = 0
	for bot in get_children():
		if bot.visible:
			if bot.position.y < minV:
				minV = bot.position.y
			if bot.position.y > maxV:
				maxV = bot.position.y


	quadTree = QuadTree.new(Rect2(-10, minV, 20, maxV - minV))

	for bot in get_children():
		if bot.visible:
			added += 1
			quadTree.insert(Vector2(bot.position.x, bot.position.y - bot.roadShift), bot)

	# print('QTF:', [added, minV, maxV])

	if ship:
		quadTree.insert(Vector2(ship.position.x, ship.position.y - ship.roadShift), ship)


func setup():
	for id in range(MAX_BOTS):
		var bot = shipScene.instance()

		var n = noise.get_noise_1d(id*10 + 1)

		bot.id = id + 1
		bot.maxSpeed = getNextMaxSpeed(bot)
		bot.originalMaxSpeed = bot.maxSpeed;
		bot.velocity.y = abs(n*1.5 + .3*sign(n));
		bot.roadShift = 0;
		bot.position.y = -id*3;
		bot.manevrity = max(.2, (randi()%10) / 20.0)

		# bot.position.x = .4 * sign(n) + n*2.3;

		bot.position.x = (randi()%4+1) - 2 - 0.5;
		bot.position.x += .2 * sign(bot.position.x)

		bot.originalX = bot.position.x;

		if bot.velocity.y < 0:
			bot.roadShift -= 20;

		add_child(bot)

	if useQuadTree:
		rebuildQuadTree()

func getNextMaxSpeed(bot):
	var n = (sin(bot.id/10 + t) * .5) + 0.5 + 0.3
	return n

func getAroundQuadTree(rad, src):
	var result = []

	result = quadTree.query(Rect2(src.position.x - rad.x, src.position.y - rad.y, rad.x * 2, rad.y * 2))
	var ownIndex = result.find(src)
	if ownIndex >= 0:
		result.remove(ownIndex)
	return result

func isBotNear(src, bot):
	var xd = abs(bot.position.x - src.position.x)
	var yd = abs((bot.position.y - bot.roadShift) - src.position.y)
	if xd < AVOID_RADIUS.x && yd < AVOID_RADIUS.y:
		return bot;
	return false

func getAround(rad, src):
	if useQuadTree:
		return getAroundQuadTree(rad, src)

	var result = []

	for bot in get_children():
		if bot.id != src.id && isBotNear(src, bot):
			result.append(bot)

	if isBotNear(src, ship):
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
			result.x += src.position.x - bot.position.x
			result.y += (src.position.y - bot.position.y) * (1.0 - yd/AVOID_RADIUS.y) * 0.2;
			yc += 1;
			xc += 1;
		if xd < 0.25 && yd < 0.5:
			collide(src, bot, xd, yd)

	if xc > 0:
		result.x /= xc;
	if yc > 0:
		result.y /= yc;

	result.x += (src.originalX - src.position.x) / (xc + 1);

	return result


func wrapPosition(bot, cameraOffset):
	var dif = abs(bot.position.y - cameraOffset)
	if dif > 100 + ship.id/5:
		bot.maxSpeed = getNextMaxSpeed(bot);
		bot.originalMaxSpeed = bot.maxSpeed;

		if bot.position.y > cameraOffset:
			bot.position.y -= 145;
		else:
			bot.position.y += 200;
		bot.position.x = (randi()%4+1) - 2 - 0.5;
		bot.position.x += .2 * sign(bot.position.x)
		bot.originalX = bot.position.x;

		bot.speed.y /= 3;

func flockBehaviour(bot):
	if !bot.visible:
		return

	var avoidVector = getAvoidVector(bot)

	bot.velocity.x = avoidVector.x * ship.manevrity;

	var speedY = avoidVector.y * (bot.speed.y/bot.maxSpeed) * .01;
	bot.speed.y += speedY;

	if bot.speed.y > bot.maxSpeed:
		bot.maxSpeed = bot.speed.y;

	if avoidVector.y == 0 && bot.maxSpeed > bot.originalMaxSpeed:
		bot.maxSpeed = max(bot.maxSpeed, bot.maxSpeed + (bot.originalMaxSpeed - bot.maxSpeed) * .2)

	if avoidVector.x == 0:
		bot.speed.x = max(0, bot.speed.x - 0.01);

func ensureVisibility(bot, cameraOffset):
	if (bot.position.y - cameraOffset) > 20:
		bot.visible = false
	else:
		bot.visible = true

	if bot.visible && (bot.position.y - cameraOffset) < -35:
		bot.visible = false

func _physics_process(delta):
	# var tStart = OS.get_ticks_usec()
	t += delta
	var cameraOffset = ship.position.y;

	for bot in get_children():
		ensureVisibility(bot, cameraOffset)
		flockBehaviour(bot)
		wrapPosition(bot, cameraOffset)


	if useQuadTree:
		rebuildQuadTree()

	# var elapsed = OS.get_ticks_usec() - tStart
	# print(elapsed)


func collide(src, target, xd, yd):
	if src.speed.z > 0 || target.speed.z > 0:
		return
	var bot = src
	if target.speed.y < bot.speed.y:
		bot = target
	bot.speed.z = .3 + (randi()%10)/100.0;

