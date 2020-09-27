shader_type spatial;
render_mode unshaded;

uniform vec4 color : hint_color = vec4(0.99, .1, .1, 1.);
uniform float seed = 0.;

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void fragment() {
    vec3 col = vec3(0.);

    vec2 uv = fract(UV * vec2(2., 1.)) - vec2(.5, .5);

    float d = .05/pow(sdBox(uv, vec2(.08, 0.02)), 1.3 + sin(seed + TIME*3.+cos(TIME*10. + sin(TIME*5.)))*.1);

    col += d * color.rgb;
    ALBEDO.rgb = col;
    ALPHA = smoothstep(0.1, .9, d);
}