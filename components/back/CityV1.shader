shader_type spatial;
render_mode unshaded;

float noise(vec2 p) {
    return fract(sin(dot(p.xy ,vec2(12.9898,78.233))) * 456367.5453);
}

void fragment() {
    // Scale coordinates to [0, 1]
    vec2 p = vec2(1.) - UV;
    // p = fract(p*vec2(1., 1.0) + vec2(0., .75));
    // p +=  .2;

    p -= .5 + sin(TIME)*.1;
    p *= 5.5 + ((sin(TIME + UV.x+UV.y) + .5)*.5);

    p+= vec2(0., .5);
    float a = atan(p.x,p.y) + sin(TIME)*.2;
    float d = pow(.7/length(p), 1.5 + cos(TIME)*.7) + sin(fract(a*2.))*.1;

    p = vec2(a,d);

    float col = 0.;
    for (int i = 1; i < 20; i++) {
        float depth = float(i);
        float step = floor(200. * p.x / depth + 50. * depth);
        if (p.y < noise(vec2(step)) - depth * .04) {
            col = depth / 20.;
        }
    }

    ALBEDO.rgb = vec3(col);
    ALPHA = step(.1, col);
}