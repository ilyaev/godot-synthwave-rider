shader_type spatial;
// render_mode unshaded;

varying vec3 world_normal;

void vertex() {
    vec4 invcamx = INV_CAMERA_MATRIX[0];
    vec4 invcamy = INV_CAMERA_MATRIX[1];
    vec4 invcamz = INV_CAMERA_MATRIX[2];
    vec4 invcamw = INV_CAMERA_MATRIX[3];

    mat3 invcam = mat3(invcamx.xyz, invcamy.xyz, invcamz.xyz);

    world_normal = NORMAL;// * invcam;
    // VERTEX.x += sin(TIME)*2.;
    // NORMAL.xyz = (CAMERA_MATRIX * vec4(NORMAL, 0.)).xyz;
}

void fragment() {
    vec2 uv = fract(UV*vec2(3., 2.));

    vec2 id = COLOR.rg;
    float h = COLOR.b;



    vec3 col = vec3(0.);

    ALBEDO.rgb = world_normal.xyz;

    if (abs(world_normal.z) != 0.) {
        // FRONT
        float frame = max(step(uv.y, .4/h), 1. - step(uv.x, .98));
        vec2 bid = floor(uv*vec2(3., h/5.));
        uv = fract(uv*vec2(3., h/5.));
        uv.y *= h;
        frame = max(frame, (1. - min(step(0.05, uv.x), (1. - step(h/1.05, uv.y)))));
        if (frame == 0.) {
            col = vec3(sin(bid.x + bid.y*2. + TIME*3.));//, cos(bid.x/2. + bid.y*2. + TIME/2.), sin(bid.x*2. + bid.y/2. + TIME*2.));
            } else {
            col = frame * vec3(1.);
        }
    }
    if (abs(world_normal.x) != 0.) {
        // SIDE
        uv.y *= h;
        col = smoothstep(h, h/2., uv.y) * vec3(1.);
    }
    if (abs(world_normal.y) != 0.) {
        // ROOF
        uv -= .5;
        col = 0.01/pow(length(uv), 2.) * vec3(0.9, .3, .1);
    }

    ALBEDO.rgb = col;
}