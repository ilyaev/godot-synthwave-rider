#define t iTime
#define MAX_STEPS 256
#define MIN_DIST 0.001
#define FAR_DIST 10.
#define PI 3.1416
#define PI2 PI*2.

struct sCamera {
    vec3 ro;
    vec3 rd;
    vec3 lookat;
    float zoom;
};


sCamera setupCamera(vec2 uv, vec3 ro, vec3 lookat, float zoom) {
    sCamera camera;
    camera.ro = ro;
    camera.lookat = lookat;
    camera.zoom = zoom;


    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = cross(f, r);
    vec3 c = ro + f * zoom;
    vec3 i = c + uv.x*r + uv.y * u;
    vec3 rd = normalize(i - ro);

    camera.rd = rd;

    return camera;
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

vec3 getAlbedoByMaterial(float material, vec3 p) {
    vec3 albedo = vec3(1.);
    if (material == 1.) {
        albedo = vec3(0., 1., 0);
        } else if (material == 0.) {
        float size = 8.;
        albedo *= step(0.0001, sin(p.x*size)+sin(p.z*size));
    }
    return albedo;
}

vec3 getDist(vec3 p) {
    float material = 0.;
    float dS = sdSphere(p - vec3(0., .5 + sin(t*2.)*.5, 0.), .5);
    float dP = sdPlane(p, 0., -.5);
    float d = dS;
    d = min(d, dP);
    if (d == dS) {
        material = 1.;
    }
    return vec3(d, material, 0.);
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

vec4 trace(vec3 ro, vec3 rd) {

    float dt, d;
    vec3 p;

    vec3 dist;

    for(int i = 0 ; i < MAX_STEPS ; i++) {
        p = ro + rd * dt;
        dist = getDist(p);
        dt += dist.x * .6;
        if (abs(dist.x) < MIN_DIST || dist.x > FAR_DIST) {
            break;
        }
    }

    return vec4(dist.x, dt, dist.xy);
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

vec3 getNormalByMaterial(float material, vec3 p) {
    vec3 normal = vec3(0., 1., 0.);
    if (material == 1.) {
        normal = getNormal(p);
    }
    return normal;
}

void mainImage(out vec4 fragColor, in vec2 fragCoords) {

    vec2 uv = fragCoords.xy / iResolution.xy;
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;

    vec2 mouse = iMouse.xy/iResolution.xy;

    vec3 col = vec3(0.);

    sCamera camera = setupCamera(
    uv,
    vec3(2.*sin(PI2 * mouse.x + t),cos((PI/2.)*mouse.y),-2.*cos(PI2 * mouse.x + t/3.)),
    vec3(0.),
    .5
    );

    vec4 tr = trace(camera.ro, camera.rd);

    float materialID = tr.a;
    float distanceTo = tr.y;

    vec3 lightPos = vec3(1., 2., -1.5);

    if (tr.x < MIN_DIST) {
        vec3 p = camera.ro + camera.rd * distanceTo;
        vec3 normal = getNormalByMaterial(materialID, p);
        vec3 albedo = getAlbedoByMaterial(materialID, p);
        vec3 diffuse = getLightColor(p, normal, lightPos);
        vec3 specular = getSpecularColor(p, normal, lightPos, camera.ro);
        float ambient = .1;
        float fade = 1.;// - abs(p.z)/5.;
        col = clamp((ambient + diffuse + specular) * albedo, 0., 1.) * fade;
    }

    fragColor = vec4(col, 1.);
    // fragColor.rgb = pow(fragColor.rgb, vec3(1.0/2.2));

}