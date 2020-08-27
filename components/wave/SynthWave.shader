shader_type spatial;
render_mode unshaded;

uniform float pos : hint_range(0, 100);
uniform vec2 size;
// uniform sampler2D noise;
uniform sampler2D noise_major;
uniform sampler2D road;
uniform vec4 grid_color : hint_color;
uniform float grid_width;
uniform bool grid_show;
uniform vec4 base_color : hint_color;
uniform bool base_color_show;
uniform vec4 road_color : hint_color;
uniform float waveYdistortion : hint_range(0, 100);
uniform float waveXdistortion : hint_range(0, 100);
uniform float mountain_sharpness : hint_range(0.2, 8.) = 1.;
uniform float mountain_height: hint_range(20, 600) = 85;
uniform float mountain_density : hint_range(0.001, 1.) = 0.55;
uniform vec3 mountain_seed = vec3(223.32, 5677., 4332.23);
uniform bool mountain_base = true;

const mat2 m = mat2(vec2( 1.6,  1.2), vec2(-1.2,  1.6 ));

vec2 hash( vec2 p ) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
    vec2 i = floor(p + (p.x+p.y)*K1);
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
    vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));
}

float fbm(vec2 n, int q) {
    float total = 0.0, amplitude = 0.03;
    for (int i = 0; i < q; i++) {
        total += noise(n) * amplitude;
        n = m * n;
        amplitude *= 0.4;
    }
    return total;
}

void vertex() {
    float t = pos * ((size - vec2(1., 1.))/size).y;
    float h = 0.0;

    // h += 1.7 * sin(VERTEX.z - t) + fract((VERTEX.z - t) / 12.);
    // h += cos(VERTEX.x / 6. + (size.x / 2.)) * sin((VERTEX.z - t) / 3.);

    float maxH = mountain_height;
    // maxH *= sin(TIME/2. + VERTEX.x*13.);

    // h += max(0., texture(noise, (UV + vec2(.3, t))).r * maxH - (maxH * .55));
    // h += max(0., texture(noise_major, (UV + vec2(0, t))).r * maxH - (maxH * .58));

    // h += Noise((UV - vec2(1.3, pos/size.y)) * mountain_sharpness, 4) * maxH - (maxH * mountain_density);
    h += (fbm((UV - vec2(1.3, pos/size.y)) * mountain_sharpness, 3) * maxH - (maxH * mountain_density));
    if (mountain_base) {
        h = max(0, h) + (fbm((UV - vec2(1.3, pos/size.y)) * 1., 2) * 600. - (maxH * mountain_density));
    }
    // h = fbm((UV - vec2(1.3, pos/size.y)) * mountain_sharpness) * maxH - (maxH * mountain_density);

    h *= texture(road, UV).r;

    VERTEX.y += max(h, 0.);

    vec2 distortion = vec2(0.);

    if (waveYdistortion != 0.) {
        distortion.y = sin((VERTEX.z - t) / waveYdistortion);
    }

    if (waveXdistortion != 0.) {
        distortion.x = sin((VERTEX.z - t) / waveXdistortion);
    }

    VERTEX.xy += distortion;

    COLOR.r = h;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void fragment() {
    vec2 uv = fract(UV * size) + .5;
    vec3 col = vec3(0.,0.,0.);
    float t = pos * ((size - vec2(1., 1.))/size).y;

    float h = COLOR.r;

    if (base_color_show) {
        vec3 vColor = smoothstep(.0, 1., h/2.) * base_color.rgb;
        col += vColor * sin(uv.x*2. - .5) * sin(uv.y * 2. - .5);
    }

    if (grid_show) {
        vec3 gvColor = grid_color.rgb * smoothstep(1., 0., h/2.);
        col += smoothstep(.0, .2, sdBox(uv - 1., vec2(.45))) * gvColor * 6.;
    }

    float shift = pos / size.y;
    float x = UV.x;
    float cRoad = step(.5408, UV.x) + step(UV.x, .4593);
    float cDelimeter = (step(.502, x) + step(x, .498));

    col *= cRoad;
    col += (1. - cRoad) *  step(.01, sin((UV.y - shift) * 60.)) * (1. - cDelimeter) * road_color.rgb;

    ALBEDO.rgb = col;
}