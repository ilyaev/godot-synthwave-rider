shader_type spatial;
// render_mode unshaded;

const bool CALCULATE_NORMALS = true;

uniform float major_noise_size = 128.;
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

vec2 getWaveDistortion(vec3 vert, float t) {
    vec2 distortion = vec2(0.);

    float sinExtra1 = 0.;
    float sinExtra2 = waveYdistortion;
    float sinExtra3 = 1.;

    if (waveYdistortion == 0.) {
        float n = texture(noise_major, vec2((vert.z - t)/major_noise_size, .5)).r;
        n -= .4;
        n *= 8.;
        n = max(0., n);
        sinExtra1 = n * 3.14;
        sinExtra2 = 15.;
        sinExtra3 = n;
    }

    float v = (vert.z - t);

    float d = sin(v / sinExtra2 ) * sinExtra3;
    d += cos(v / (sinExtra2 * 2.0));
    d -= sin(v / (sinExtra2 * 4.0));
    // d = abs(d);
    // d = max(0., d);

    distortion.y = d;

    if (waveXdistortion != 0.) {
        distortion.x = sin((vert.z - t) / waveXdistortion);
    }
    return distortion;
}

float N21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}

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

float getHeight(vec3 p, float t, float time, vec2 uv) {
    float h = 0.0;
    float n = N21(vec2(p.x, p.x));
    float morphSpeed = 16.;
    float tScaled = (time + (p.z - t) + n)/morphSpeed;

    float hId = floor(tScaled);
    float maxH = mountain_height;

    float mHeight = (fbm((uv - vec2(1.3 + hId, pos/size.y)) * mountain_sharpness, 3) * maxH - (maxH * mountain_density));
    float mHeightNext = (fbm((uv - vec2(1.3 + hId + 1., pos/size.y)) * mountain_sharpness, 3) * maxH - (maxH * mountain_density));


    h += mix(mHeight, mHeightNext, fract(tScaled));

    if (mountain_base) {
        h = max(0, h) + (fbm((uv - vec2(1.3, pos/size.y)) * 1., 2) * 600. - (maxH * mountain_density));
    }

    h *= texture(road, uv).r;
    return max(0., h);
}

void vertex() {
    float t = pos * ((size - vec2(1., 1.))/size).y;

    float h = getHeight(VERTEX, t, TIME, UV);

    if (CALCULATE_NORMALS) {
        float h1 = getHeight(VERTEX + vec3(1., 0., 1.), t, TIME, UV);
        float h2 = getHeight(VERTEX + vec3(1., 0., 0.), t, TIME, UV);

        vec3 o = vec3(0., h, 0.);
        vec3 o1 = vec3(1., h1, 1.);
        vec3 o2 = vec3(1., h2, 0.);

        NORMAL = (CAMERA_MATRIX * vec4(cross(o1-o, o2-o), 0.0)).xyz;
    }

    VERTEX.y += h;

    vec2 distortion = getWaveDistortion(VERTEX, t); //vec2(0.);

    // if (waveYdistortion != 0.) {
        //     distortion.y = sin((VERTEX.z - t) / waveYdistortion);
        //     } else {
        //     float nd = max(0., texture(noise_major, vec2((VERTEX.z - t)/major_noise_size, .5)).r - 0.3);
        //     distortion.y += nd*4.;
    // }

    // if (waveXdistortion != 0.) {
        //     distortion.x = sin((VERTEX.z - t) / waveXdistortion);
    // }

    VERTEX.xy += distortion;



    COLOR.r = h;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

vec3 draw(vec2 gUV, vec4 gCOLOR, vec2 uvShift, vec3 vert) {
    vec2 uv = fract(gUV * size) + .5 + uvShift;
    // vec2 id = floor(gUV * size);
    vec3 col = vec3(0.,0.,0.);
    float t = pos * ((size - vec2(1., 1.))/size).y;

    float h = gCOLOR.r;

    if (base_color_show) {
        vec3 vColor = smoothstep(.0, 1., h/2.) * base_color.rgb;
        col += vColor * sin(uv.x*2. - .5) * sin(uv.y * 2. - .5);
    }

    if (grid_show) {
        vec3 gvColor = grid_color.rgb * smoothstep(1., 0., h/2.);
        //float zScale = UV.y - 1.;
        //zScale *= min(.3, smoothstep(.8, 0., UV.y));
        //zScale *= smoothstep(0., h, .1);
        float zScale = 0.;
        col += (smoothstep(.0, .2, sdBox(uv - 1., vec2(.45 + zScale))) * gvColor * 6.);
    }

    float shift = pos / size.y;
    float x = gUV.x;
    float cRoad = step(.5408, gUV.x) + step(gUV.x, .4593);
    float cDelimeter = (step(.502, x) + step(x, .498));

    // vec3 rc = road_color.rgb;
    // float rh = max(0., texture(noise_major, vec2((vert.z - t)/major_noise_size, .5)).r * 4. - .5);
    // rc = vec3(rh - 1.3);
    // return rc;

    col *= cRoad;
    col += (1. - cRoad) *  step(.01, sin((gUV.y - shift) * 60.)) * (1. - cDelimeter) * road_color.rgb * 3.;

    return col;
}

void fragment() {
    vec3 col = vec3(0.);

    col = draw(UV, COLOR, vec2(0.), VERTEX);
    // col = NORMAL.xyz;

    ALBEDO.rgb = col;
}