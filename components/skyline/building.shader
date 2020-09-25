shader_type spatial;
// render_mode unshaded;

varying vec3 world_normal;
varying flat vec2 id;
varying flat float height;
varying flat float width;

const float windowsPerRow = 8.;
const vec3 frameColor = vec3(0.);


float n21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}


void vertex() {
    world_normal = NORMAL;
    id = INSTANCE_CUSTOM.xy;
    height = INSTANCE_CUSTOM.z;
    width = INSTANCE_CUSTOM.a;
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

    return col;
}

vec3 getSideTexture(vec2 ouv, float t) {
    vec2 uv = ouv;
    uv.y *= height;
    vec3 col = smoothstep(height, height / 2., uv.y) * vec3(.1);// * vec3(sin(t), cos(t), cos(t/2.));
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