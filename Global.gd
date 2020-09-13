extends Node

var current_scene = null

var waveYdistortion = 15
var noiseTexture
var noiseSize
var noiseY = 64
var debug = false
var prev = 0

func setWaveNoise(nt):
    noiseSize = nt.get_size().x
    noiseY = int(noiseSize / 2)
    noiseTexture = nt.noise.get_seamless_image(noiseSize)
    noiseTexture.lock()

func getNoiseValue(value):
    var result = fmod(value, noiseSize)
    if result < 0:
        result = noiseSize + result
    return noiseTexture.get_pixel(int(result), noiseY).r

func getWaveNoise(x, _y):
    var n1 = getNoiseValue(int(x))
    var n2 = getNoiseValue(int(x) + sign(x))
    var f = abs(fmod(x, 1))
    var n = lerp(n1, n2, f);
    return n


func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)


func getDistortionY(pos, shift, extra):
    var sinExtra1 = 0;
    var sinExtra2 = waveYdistortion;
    var sinExtra3 = 1;
    var n = 0;

    if waveYdistortion == 0.0:
        n = getWaveNoise((shift - pos), noiseY);
        n -= .4;
        n *= 8.0;
        n = max(0, n);
        sinExtra1 = n * 3.14;
        sinExtra2 = 15;
        sinExtra3 = n;

    # if debug:
    #     print([shift, pos, n, sinExtra2])

    var v = (shift - pos);

    var d = sin(v / sinExtra2) * sinExtra3;
    d += cos(v / (sinExtra2 * 2.0));
    d -= sin(v / (sinExtra2 * 4.0));
    # d = abs(d)
    # d = max(0, d);

    return d + extra;