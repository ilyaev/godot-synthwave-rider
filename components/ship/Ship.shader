shader_type spatial;
// render_mode unshaded;

uniform vec3 color = vec3(1.);

void fragment() {
    vec2 uv = fract(UV*vec2(3., 2.));

    vec3 col = vec3(0.9, 0.8, 0.9);

    // col = 0.2/distance(uv, vec2(.5 + sin(TIME)*0.3,.5)) * vec3(0.3,0.1, 0.);

    float frame = 0.;

    // frame += step(uv.x, .1) + step(.9, uv.x);
    // frame += step(uv.y, .1) + step(.9, uv.y);

    // frame += pow(.1/uv.x, 2.5);
    // frame += pow(.1/(uv.x - 1.), 2.5);
    // frame += pow(.1/uv.y, 2.5);
    // frame += pow(.1/(uv.y - 1.), 2.5);

    // ALBEDO.rgb = col * frame;
    ALBEDO.rgb = NORMAL.xyz + frame*col;
}