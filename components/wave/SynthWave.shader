shader_type spatial;


uniform float pos;
uniform vec2 size;
uniform sampler2D noise;
uniform sampler2D road;
uniform vec4 grid_color : hint_color;
uniform float grid_width;
uniform bool grid_show;
uniform vec4 base_color : hint_color;

float N21(vec2 p) {
    return fract(sin(p.x*223.32+p.y*5677.)*4332.23);
}

void vertex() {
    float t = pos * ((size - vec2(1., 1.))/size).y;
    float h = 0.0;

    h += 1.7 * sin(VERTEX.z - t) + fract((VERTEX.z - t) / 2.);
    h += cos(VERTEX.x) * sin(VERTEX.z - t);

    float maxH = 85.;
    // maxH *= sin(TIME*2. + VERTEX.x*13.);

    h += max(0., texture(noise, (UV + vec2(0, t))).r * maxH - (maxH * .55));

    h *= texture(road, UV).r;// + sin(TIME)*.2;

    VERTEX.y += max(h, 0.);
}

void fragment() {
    vec2 uv = fract(UV * size) + .5;
    vec3 col = vec3(0.,0.,0.);

    if (grid_show) {
        float grid = pow(grid_width/uv.x, 5.); //step(uv.x, grid_width);
        grid += pow(grid_width/uv.y,5.);
        col += grid_color.rgb * grid;
    }


    col += base_color.rgb * sin(uv.x*2. - .5) * sin(uv.y * 2. - .5);
    // ALBEDO.r +=

    ALBEDO.rgb = col;
    // ALBEDO.r += uv.x * uv.y;


    //ALBEDO.rgb = vec3(0.);

    //ALBEDO.g = uv.x * uv.y;// * (step(UV.x, .47) + step(.53, UV.x));
    // ALBEDO.r = step(.9, uv.x) + step(.9, uv.y);
    // ALBEDO.r = pow(1./length(uv - .5) * .05, 2.2);
    // float d = (VERTEX.z + size.y / 2.) / size.y;
    // ALBEDO.r *= d;
    // if (d < .05) {
        // 	ALPHA = .0
    // }
    // if (VERTEX.z > 30.) {
        // 	ALPHA = 1. - VERTEX.y / 20.;
    // }
}