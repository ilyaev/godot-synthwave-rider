shader_type spatial;
render_mode unshaded;

uniform float pos;
uniform vec2 size;
uniform sampler2D noise;
uniform sampler2D noise_major;
uniform sampler2D road;
uniform vec4 grid_color : hint_color;
uniform float grid_width;
uniform bool grid_show;
uniform vec4 base_color : hint_color;
uniform bool base_color_show;
uniform vec4 road_color : hint_color;

float N21(vec2 p) {
    return fract(sin(p.x*223.32+p.y*5677.)*4332.23);
}

void vertex() {
    float t = pos * ((size - vec2(1., 1.))/size).y;
    float h = 0.0;

    // h += 1.7 * sin(VERTEX.z - t) + fract((VERTEX.z - t) / 12.);
    h += cos(VERTEX.x / 6. + (size.x / 2.)) * sin((VERTEX.z - t) / 3.);

    float maxH = 85.;
    // maxH *= sin(TIME/2. + VERTEX.x*13.);

    h += max(0., texture(noise, (UV + vec2(0, t))).r * maxH - (maxH * .55));
    h += max(0., texture(noise_major, (UV + vec2(0, t))).r * maxH - (maxH * .55));

    h *= texture(road, UV).r;

    VERTEX.y += h;// max(h, 0.);

    vec2 distortion = vec2(0.);

    distortion.y = sin((VERTEX.z - pos) / 10.);
    // distortion.y += texture(noise_major, (vec2((VERTEX.z - pos), .1))).r;

    // distortion.x = sin((VERTEX.z - pos) / 10.); // + TIME * 0.) * sin(TIME);

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