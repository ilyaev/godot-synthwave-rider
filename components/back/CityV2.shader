shader_type spatial;
render_mode unshaded;

uniform float t : hint_range(0, 100) = 0;
uniform sampler2D noise;
uniform vec3 LightPosition = vec3(1., 2., -1.5);
uniform float noiseSeed : hint_range(1, 2000) = 1320.;

const int MAX_STEPS = 256;
const float MIN_DIST = 0.001;
const float FAR_DIST = 10.;
const float PI = 3.1416;
const float PI2 = PI*2.;

const float defaultBaseSize = .1;
const float defaultBaseSpacing = .3;
const vec3 bounds = vec3(150.0, .0, 2.);
const float cityShiftSpeed = 8.;

float N21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}

mat2 rot2d(float a) {
    float sa = sin(a);
    float ca = cos(a);
    return mat2(vec2(sa, ca), vec2(-ca, sa));
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

float getBuildingHeight(vec3 id, float n) {
    float tScaled = t / cityShiftSpeed;
    float bh = .4 + id.z/2.;
    bh *= min(1., n + .7);
    bh += sin(tScaled+n*15.)*n*.01;
    bh += .2 - abs(id.x/3.)*.15;
    return bh;
}

float getBuildingNoise(vec3 id, float iTime) {
    return N21(vec2((id.x + 1.)*(id.z + 1.) + noiseSeed + floor(iTime)));
}

float getCubes(vec3 p) {
    float baseSpacing = defaultBaseSize + defaultBaseSpacing/2.;
    p.y += .3;


    vec3 l = bounds;
    vec3 rc1 = vec3(vec2(baseSpacing), 3.);
    vec3 id = round(p/rc1);
    vec3 q1 = p - rc1 * clamp(id, -l, l);

    float tScaled = t / cityShiftSpeed;

    float n = getBuildingNoise(id, floor(tScaled));
    float n1 = getBuildingNoise(id, floor(tScaled + 1.));

    q1.z += mix((n - .5) * .5, (n1 - .5) * .5, fract(tScaled));
    q1.z += mix(sin(tScaled/3.+n*13.)*n*.2, sin(tScaled/3.+n1*13.)*n1*.2, fract(tScaled));

    q1.xz *= rot2d(mix(id.x + fract(n*322.33) + sin(tScaled+n*PI)*n*3., id.x + fract(n1*322.33) + sin(tScaled+n1*PI)*n1*3., fract(tScaled)));

    float bw = .1 * min(1., mix(fract(n*123.33) + .4, fract(n1*123.33) + .4, fract(tScaled)));
    float bh = mix(getBuildingHeight(id, n), getBuildingHeight(id, n1), fract(tScaled));

    q1.y -= bh - id.z/2.;

    return sdBox(q1, vec3(bw, bh, bw*mix(max(.5, n), max(.5,n1), fract(tScaled)))) * .7;
}

vec3 getDist(vec3 p) {
    float material = 0.;
    float dS = getCubes(p - vec3(0., 0., 0.))*.6;
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
        dt += dist.x;
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
        albedo = vec3(1., 1., 1.);
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

    // float distanceToLight = trace(p + n * (MIN_DIST*2.), l).x;
    // if (distanceToLight < length(lightPos - p)) {
        //     dif *= .5;
    // }

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
    vec2 uv = (vec2(1.) - UV) - .5;
    // uv /= 5.5;

    uv += vec2(0., .05);
    // float a = atan(uv.x, uv.y);
    // float d = .04/length(uv);
    // uv = vec2(a,d);
    // float a = atan(uv.x,uv.y) + sin(TIME)*.2;
    // float d = pow(.7/length(uv), 1.5 + cos(TIME)*.7) + sin(fract(a*2.))*.1;



    // float t = TIME;
    float ot = 1.;

    // vec3 ro = vec3(0. + ot*sin(t)*PI, 0. + ot*cos(t)*PI, -3.);
    // vec3 ro = vec3(sin(t/2.)*.3, 0., -3.+sin(t*3.)*.05);
    vec3 ro = vec3(0.,0.,-3.);
    vec3 lookat = vec3(0.);
    float zoom = .6;// + sin(t)*.3;

    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = cross(f, r);
    vec3 c = ro + f * zoom;
    vec3 i = c + uv.x*r + uv.y*u;
    vec3 rd = normalize(i - ro);

    vec4 tr = trace(ro, rd);
    float materialID = tr.a;
    float distanceTo = tr.y;

    vec3 lightPos = LightPosition;  //vec3(1. + cos(TIME*0.)*3., 2. + sin(TIME*3.*0.), -1.5);

    if (tr.x < MIN_DIST) {
        vec3 p = ro + rd * distanceTo;
        col = vec3(1.);
        vec3 normal = getNormalByMaterial(materialID, p);
        vec3 albedo = getAlbedoByMaterial(materialID, p);
        vec3 diffuse = getLightColor(p, normal, lightPos);
        vec3 specular = vec3(0.);
        // vec3 specular = getSpecularColor(p, normal, lightPos, ro);
        float ambient = .1;
        float fade = 1. - abs(p.z)/5.;
        col = clamp((ambient + diffuse + specular) * albedo, 0., 1.) * fade;
    }


    // col += DrawPoint(ro, rd, vec3(sin(TIME)*.2, cos(TIME)*.2, sin(TIME*10.)*.9));// * vec3(1., 0., 0.);
    // col += vec3(step(.2, uv.y));
    ALBEDO.rgb = col;
    // ALPHA = smoothstep(0.,.00001, col.r + col.g + col.b);
    // ALPHA = col.g;
}