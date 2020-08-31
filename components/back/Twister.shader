shader_type spatial;
render_mode unshaded;

uniform float t : hint_range(0, 2) = 0;

const int MAX_STEPS = 256;
const float MIN_DIST = 0.001;
const float FAR_DIST = 10.;
const float PI = 3.1416;
const float PI2 = PI*2.;



const float defaultBaseSize = .1;
const float defaultBaseSpacing = .3;
const vec3 bounds = vec3(3.0, 3.0, 1.);

const float LAYERS = 3.;
const float LAYER_SIZE = 1.;
const float twisterBaseSize = .05;
const vec3 twisterBaseSpacing = vec3(twisterBaseSize * 3.);
const vec3 twisterBounds = vec3(LAYER_SIZE, LAYER_SIZE, LAYERS);

mat2 rot2d(float a) {
    float sa = sin(a);
    float ca = cos(a);
    return mat2(vec2(sa, ca), vec2(-ca, sa));
}

float N21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}

float DistLine(vec3 ro, vec3 rd, vec3 p) {
    return length(cross(rd, p - ro))/length(rd);
}


float DrawPoint(vec3 ro, vec3 rd, vec3 p) {
    float d = DistLine(ro, rd, p);
    return 1. - step(.05, d);
}

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

float sdBox( vec3 p, vec3 b ) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdPlane(vec3 p, float x, float y) {
    return p.y - y;
}

float getTwister(vec3 p) {
    float iTime = t;
    p.z += t;
    // X-axis rotation
    // float xa = PI/2.;
    // p.yz *= rot2d(xa);

    // Z-axis rotation
    // float za = 0. - t*3.;//PI/2.;
    // p.xy *= rot2d(za);

    vec3 rc1 = vec3(twisterBaseSpacing);
    vec3 id = round(p/rc1).xyz;

    float sn = 1.;
    if (id.x == 2.) {
        sn = -1.;
    }

    // z-layer interval scale
    // rc1.xy *= (1. + (sin(id.z/5. + iTime*3.) * .5 + .5)*1.);
    // z-layer rotation
    float zra = id.z/20. * PI - t;//sin(id.z + iTime * id.z*.01)*6.28;
    p.xy *= rot2d(zra);

    vec3 q1 = p - rc1 * round(p/rc1);
    id = round(p/rc1).xyz;

    // float n = N21(vec2(id.x * id.y, id.z * id.x*id.z));

    // float maxShift = twisterBaseSize * 2.;
    vec3 shift = vec3(0.);//vec3(maxShift * (n - .5), maxShift * (fract(n*567.43) - .5), maxShift * (fract(n*12567.43) - .5));

    // float dt = length(q1 + shift) - twisterBaseSize / 2.;
    vec3 pp = q1 + shift;
    // float n = N21(vec2(id.x, id.z));
    // pp.xz *= rot2d(pp.z + t*((n - .5) * 16.));
    // pp.xy *= rot2d(pp.z + t*((n - .5) * 16.));
    float dt = sdBox(pp, vec3(twisterBaseSize / 4.));
    float len = length(id.xy);
    if (id.x == 1. && id.y == 1.) {
        return dt;
    }
    if (id.x == 2. && id.y == 2.) {
        return dt;
    }
    return .1;
    if ( len < 1. || len > 2.) {
        dt = .1;
    }
    return dt;
}

vec3 getDist(vec3 p) {
    float material = 0.;
    float dS = getTwister(p);
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
        dt += dist.x * .5;
        if (abs(dist.x) < MIN_DIST || dist.x > FAR_DIST) {
            break;
        }
    }

    return vec4(dist.x, dt, dist.xy);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0.);
    float d = getDist(p).x;
    vec3 n = d - vec3(
    getDist(p - e.xyy).x,
    getDist(p - e.yxy).x,
    getDist(p - e.yyx).x
    );
    return normalize(n);
}

vec3 getNormalByMaterial(float material, vec3 p) {
    vec3 normal = vec3(0., 1., 0.);
    if (material == 1.) {
        normal = getNormal(p);
    }
    return normal;
}

vec3 getAlbedoByMaterial(float material, vec3 p) {
    vec3 albedo = vec3(1.);
    if (material == 1.) {
        albedo = vec3(0., 1., 0.);
        // albedo = vec3(cos(p.x*p.y - t/2.), 1., sin(p.x*p.y + t)) * abs(p.z);
        // albedo = vec3(sin(t)*cos(t*2.), sin(t), cos(t));
        } else if (material == 0.) {
        float size = 8.;
        albedo *= step(0.0001, sin(p.x*size)+sin(p.z*size));
    }
    return albedo;
}

vec3 getLightColor(vec3 p, vec3 n, vec3 lightPos) {
    vec3 l = normalize(lightPos - p);
    float dif = clamp(0., 1., dot(n,l));

    float distanceToLight = trace(p + n * (MIN_DIST*2.), l).x;
    if (distanceToLight < length(lightPos - p)) {
        dif *= .5;
    }

    return vec3(dif);
}

vec3 getSpecularColor(vec3 p, vec3 n, vec3 lightPos, vec3 viewPos) {
    vec3 spec = vec3(0.);
    float specularStrength = 0.5;

    vec3 viewDir = normalize(p - viewPos);
    vec3 reflectDir = reflect(normalize(lightPos - p), n);
    float specValue = pow(max(dot(viewDir, reflectDir), 0.), 32.);


    return spec + specularStrength * specValue;
}

void fragment() {
    vec3 col = vec3(0.);
    vec2 uv = (1. - UV) - .5;

    float a = atan(uv.x, uv.y);
    float d = length(uv);

    // uv = vec2(a,d);

    // float t = TIME;
    float ot = 0.;

    // vec3 ro = vec3(0. + ot*sin(t)*PI, 0. + ot*cos(t)*PI, -3.);
    // vec3 ro = vec3(0. + ot*sin(t)*PI, 0. + ot*cos(t)*PI, -3.);
    vec3 ro = vec3(0., 0., -1.);
    // ro.zy = ro.zy * rot2d(PI);
    vec3 lookat = vec3(0. + ot*sin(t));
    float zoom = 1. + ot*sin(t)*.3;

    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = cross(f, r);
    vec3 c = ro + f * zoom;
    vec3 i = c + uv.x*r + uv.y*u;
    vec3 rd = normalize(i - ro);

    vec4 tr = trace(ro, rd);
    float materialID = tr.a;
    float distanceTo = tr.y;

    vec3 lightPos = vec3(1. + cos(TIME)*3., 2. + sin(TIME*3.), -1.5);

    if (tr.x < MIN_DIST) {
        vec3 p = ro + rd * distanceTo;
        col = vec3(1.);
        vec3 normal = getNormalByMaterial(materialID, p);
        vec3 albedo = getAlbedoByMaterial(materialID, p);
        vec3 diffuse = getLightColor(p, normal, lightPos);
        vec3 specular = vec3(0.);
        // vec3 specular = getSpecularColor(p, normal, lightPos, ro);
        float ambient = .1;
        float fade = 1.;// - abs(p.z)/5.;
        col = clamp((ambient + diffuse + specular) * albedo, 0., 1.) * fade;
    }


    // col += DrawPoint(ro, rd, vec3(sin(TIME)*.2, cos(TIME)*.2, sin(TIME*10.)*.9));// * vec3(1., 0., 0.);
    // col += vec3(step(.2, uv.y));
    ALBEDO.rgb = col;
    ALPHA = smoothstep(0.,.00001, col.r + col.g + col.b);
    // ALPHA = col.g;
}