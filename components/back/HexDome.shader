shader_type spatial;
render_mode unshaded;

const int MAX_STEPS = 256;
const float MIN_DIST = 0.001;
const float FAR_DIST = 10.;
const float PI = 3.1416;
const float PI2 = PI*2.;

float hexDist(vec2 uv) {
    uv = abs(uv);
    return max(uv.x, dot(uv, normalize(vec2(1., 1.73))));
}

vec4 hexCoords(vec2 uv) {


    vec2 r = vec2(1., 1.73);
    vec2 h = r * .5;

    vec2 a = mod(uv, r) - h;
    vec2 b = mod(uv - h, r) - h;

    vec2 gv;

    if (length(a) < length(b)) {
        gv = a;
        } else {
        gv = b;
    }

    float x = atan(gv.x, gv.y);
    float y = .5 - hexDist(gv);

    vec2 id = uv - gv;

    return vec4(x, y, id.xy);
}

float N21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}

mat2 rot2d(float a) {
    float sa = sin(a);
    float ca = cos(a);
    return mat2(vec2(sa, ca), vec2(-ca, sa));
}


float getSky(vec3 p) {
    return -(length(p) - 10.);
}


vec3 getDist(vec3 p) {
    float material = 0.;
    float dS = getSky(p);
    float d = dS;
    material = 1.;
    return vec3(d, material, 0.);
}

vec4 trace(vec3 ro, vec3 rd) {
    float dt, d;
    vec3 p;

    vec3 dist;

    for(int i = 0 ; i < MAX_STEPS ; i++) {
        p = ro + rd * dt;
        dist = getDist(p);
        dt += dist.x * .8;
        if (abs(dist.x) < MIN_DIST || dist.x > FAR_DIST) {
            break;
        }
    }

    return vec4(dist.x, dt, dist.xy);
}

vec3 getSkyTexture(vec3 p, float t) {
    float shipShift = 0.;
    float velocity = 20.;

    vec3 col = vec3(.0);

    t /= 10.;

    vec3 q1 = p + vec3(sin(t)*5.,0., cos(t)*5.);
    q1.yz *= rot2d(PI/2.5 + PI/2.05);
    p = q1;



    float scale = 1.5;

    float n = N21(vec2(floor(t), 342.)) - .5;
    float n1 = N21(vec2(floor(t) + 1., 342.)) -.5;

    scale += .5 * mix(n, n1, fract(t));

    vec4 hex = hexCoords(p.xy*vec2(1., 1.0)*vec2(scale, scale * 2.) - vec2(shipShift*.5, shipShift*.2*sign(shipShift)));// + vec2(iTime, iTime*1.2));//*(1. + (sin(iTime)*.5 + .5)*5.));

    float flick = smoothstep(.9, 1., sin(n + n1*4. + t + sin(t)/cos(t + sin(t*3.+t) + n)) * .5 + .5) * step(10., velocity);


    vec3 gridColor = mix(vec3(0., 1., 1.), mix(vec3(1.,0.,0.), vec3(0.,1.,0.), sin(t + n*10.)), cos(t/2. + n1*5.));

    float matte = .5;
    float mn = N21(abs(hex.ba) + floor(t)) - .5;
    float mn1 = N21(abs(hex.ba) + floor(t + 1.)) -.5;

    matte += 1. * mix(mn, mn1, fract(t));

    col += pow(.01/hex.y, 1.7) * gridColor;
    col += min(.5, matte) * vec3(1.);//gridColor;

    col *= flick;

    return col;
}

vec3 getAlbedoByMaterial(float material, vec3 p, float t) {
    vec3 albedo = vec3(1.);
    if (material == 1.) {
        albedo = getSkyTexture(p, t);
    }
    return albedo;
}


void fragment() {
    vec3 col = vec3(0.);
    vec2 uv = (1. - UV) - .5;

    // float a = atan(uv.x, uv.y);
    // float d = length(uv);

    // uv = vec2(a,d);

    vec3 ro = vec3(0., 0., -3.);
    vec3 lookat = vec3(0.);
    float zoom = 1.;

    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = cross(f, r);
    vec3 c = ro + f * zoom;
    vec3 i = c + uv.x*r + uv.y*u;
    vec3 rd = normalize(i - ro);

    vec4 tr = trace(ro, rd);
    float materialID = tr.a;
    float distanceTo = tr.y;

    if (tr.x < MIN_DIST) {
        vec3 p = ro + rd * distanceTo;
        col = getAlbedoByMaterial(materialID, p, TIME);
    }

    ALBEDO.rgb = col;
    ALPHA = clamp(col.r + col.g + col.b, 0., 1.);// length(col);
    ALPHA += step(0., sin(TIME)) * 1.;
    // ALPHA = 1. - smoothstep(0., .8, col.r);

}