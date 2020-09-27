shader_type spatial;
// render_mode unshaded;

varying vec3 world_normal;
varying flat vec2 id;
varying flat float height;
varying flat float width;
varying flat float depth;

const float windowsPerRow = 8.;
const vec3 frameColor = vec3(0.);

uniform vec4 color_circles : hint_color = vec4(.9, .0, .1, 1.);
uniform vec4 color_road : hint_color = vec4(1.);

float n21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}


void vertex() {
    world_normal = NORMAL;
    id = INSTANCE_CUSTOM.xy;
    height = INSTANCE_CUSTOM.z;
    width = INSTANCE_CUSTOM.a;
    depth = COLOR.r;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

mat2 rot2d(float a) {
    float sa = sin(a);
    float ca = cos(a);
    return mat2(vec2(sa, ca), vec2(-ca, sa));
}

vec3 sceneCircles(vec2 uv, float t) {
    float d = length(uv + vec2(sin(t*2.)*5., cos(t*2.)*5.)) - t*10.;
    // return step(mod(d, 20.), 1.) * vec3(.9, .3, .1);
    return (.5/mod(d, 20.)) * color_circles.rgb; // abs(sin(color_circles.rgb + t));
}

vec3 sceneParticles(vec2 uv, float t) {

    vec2 sid = (uv*vec2(2., 8.)) - mod(uv*vec2(2., 8.), vec2(80., 70.));
    float n = n21(sid + vec2(4.,32.));
    uv.x -= t*(20. * n*2.);
    uv.y += sin(t*3.*fract(n*123.4)*2.)*3.;
    uv = mod(uv*vec2(2., 8.), vec2(80., 70.));

    // float d = step(sdBox(uv, vec2(4., 16.)), .01);
    float d = 3./pow(sdBox(uv, vec2(4., 16.)), 2.7);
    return d * vec3(.3, .9, 0.1);
}

vec3 sceneSquares(vec2 uv, float t) {
    uv *= rot2d(t);
    // uv += vec2(t);
    // uv = mod(uv*8., 80.);
    float d = sdBox(uv, vec2(15.));// - abs(sin(t*3.))*cos(t)*8.));
    // return (5.1/pow(d, 4.5)) * vec3(0.9, .3, .1);
    // d = mod(d*10., 5.);
    return step(d, .5) * vec3(.9, .3, .1)*.1;
}

vec3 getFrontTexture(vec2 ouv, float t) {
    vec3 col = vec3(0.);

    float frame = max(step(ouv.y, .4 / height), 1. - step(ouv.x, .98));

    vec2 nextUV = ouv * vec2(width, height);
    vec2 wid = floor(nextUV);
    vec2 uv = fract(nextUV);

    uv.y *= height;

    float frameSize = 0.05 * max(1., (width / 2.));

    frame = max(frame, (1. - min(step(frameSize, uv.x), (1. - step(height / (1. + frameSize), uv.y)))));

    // frame = 0.;

    float n = n21(wid + id);// + floor((t + (wid.y+wid.x)/windowsPerRow + id.x/5.)/6.));

    if (frame == 0.) {
        col = step(clamp(fract(n*1234.), .6, .9), n) * vec3(n, .3, .1) * clamp(vec3(sin(wid.x + wid.y * 2.*sign(n-.7) + t/(1. + fract(n*1234.22)))), 0., 1.);
        } else {
        col = frame * frameColor;
    }


    vec2 center = vec2((10. * width)/2., 50./2.);
    vec2 gid = vec2(wid.x + id.x * width, height - wid.y) - center;



    // sun
    // float d = 5./pow(length(gid + vec2(sin(t)*20., 0.)), 1.3);
    // col += d * vec3(.9, .3, .1);


    // line
    // gid /= 1. + abs(sin(t)*3.);
    // gid *= rot2d(sin(t)*6.28/12. + 3.14/2.);
    // col += (step(0., gid.y) - step(2., gid.y)) * vec3(0.6);

    col += sceneCircles(gid, t) * frame;
    col = max(col, sceneParticles(gid, t) * (1. - frame));
    col = max(col, sceneSquares(gid, t));//* (1. - frame));

    return col;
}

vec3 getSideTexture(vec2 ouv, float t) {
    vec2 uv = ouv * vec2(depth, height) + vec2(0., -t*8.);
    vec3 col = smoothstep(height, height / 2., abs(uv.y)) * vec3(.1);// * vec3(sin(t), cos(t), cos(t/2.));
    float road = step(.0001, sin(uv.x)*cos(uv.y*1.2)) * (step(depth/2. - .3, uv.x) - step(depth/2. + .3, uv.x));
    col += road * color_road.rgb;
    return col;
}

vec3 getRoofTexture(vec2 ouv, float t) {
    vec2 uv = ouv - .5;
    vec3 col = 0.01/pow(length(uv), 2.) * vec3(0.9, .3, .1);
    return col;
}


void fragment() {
    vec2 uv = fract(UV*vec2(3., 2.));

    float h = height;
    float t = TIME;

    vec3 col = vec3(0.);

    ALBEDO.rgb = world_normal.xyz;

    bool isWalls = true;

    if (abs(world_normal.z) != 0.) {
        // FRONT
        col = getFrontTexture(uv, TIME);
    }
    if (abs(world_normal.x) != 0.) {
        // SIDE
        col = getSideTexture(uv, TIME);
    }
    if (abs(world_normal.y) != 0.) {
        // ROOF
        col = getRoofTexture(uv, TIME);
        isWalls = false;
    }

    if (isWalls) {
        // backlight
        col += (1. - smoothstep(height, height / (2. + (sin(t)*.5 + .5)*3.), uv.y * height))*.1*vec3(sin(t+uv.y), cos(t+uv.y), sin(t/2.+uv.y));
    }

    float fade = 1. - id.y * 0.4;

    ALBEDO.rgb = col * fade;
    // ALPHA = step(col.g, .3);
    // METALLIC = 0.;
    // SPECULAR = 1.;
    // CLEARCOAT = 1.;
    // CLEARCOAT_GLOSS = 1.;
    // EMISSION = vec3(0., .4, 0.);
    // TRANSMISSION = vec3(.5);
    // RIM = .1;
    // RIM_TINT = 0.;
    // ROUGHNESS = 0.;
}