extends Node

var current_scene = null

var waveYdistortion = 15
var noiseTexture
var noiseSize
var noiseY = 64

func setWaveNoise(nt):
    # var wn = nt.noise
    noiseSize = nt.get_size().x
    noiseY = int(noiseSize / 2)
    noiseTexture = nt.noise.get_seamless_image(noiseSize)
    noiseTexture.lock()

func getNoiseValue(value):
    var result = fmod(value, noiseSize)
    if result < 0:
        result = noiseSize + result
    var nd = max(0, noiseTexture.get_pixel(result, noiseY).r * 4 - .5);
    return nd * 4; #noiseTexture.get_pixel(result, noiseY).r * 4

func getWaveNoise(x, _y):
    var n1 = getNoiseValue(int(x))
    var n2 = getNoiseValue(int(x + sign(x)))
    # print(abs(fmod(x, 1)))
    return n1 + (n2-n1) * abs(fmod(x, 1))


func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)


func getDistortionY(pos, shift, extra):
    if waveYdistortion > 0:
        return sin((shift - pos) / waveYdistortion) + extra
    else:
        return getWaveNoise((shift - pos), noiseY) + extra
        # return 	(waveNoise.get_noise_2d((shift - pos) + extra, 23.3) + 1) / 2 * 4.0

# func getDistortionY(pos, shift, extra):
#     # return noise.get_pixel((shift - pos) + extra, 23.3).r;
#     return 	(waveNoise.get_noise_2d((shift - pos) + extra, 23.3) + 1) / 2 * 4.0
