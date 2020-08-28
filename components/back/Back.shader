shader_type spatial;
render_mode unshaded;

void fragment() {
    // ALBEDO.rgb = vec3(1., 0., 0.);
    // vec2 uv = fract(UV * 10.);
    float d = pow(.05/length(UV - .5), 1.);
    ALBEDO.rgb = vec3(0.9, .3, .2) * d;
    // ALPHA = ALBEDO.r + ALBEDO.g + ALBEDO.b;
    vec2 uv = UV;
    // ALPHA = 1. - step(.2, fract(length(uv - vec2(0.5, 0.58))*10. - TIME));
    // ALPHA = step(length(uv-0.5), .1) * step(sin(uv.y*320. + TIME*3.) * step(.5, uv.y), .3);
}