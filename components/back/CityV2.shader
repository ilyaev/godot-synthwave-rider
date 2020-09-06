shader_type spatial;
render_mode unshaded;

uniform float t : hint_range(0, 100) = 0;
uniform sampler2D noise;
uniform vec3 LightPosition = vec3(1., 2., -1.5);
uniform float noiseSeed : hint_range(1, 2000) = 1320.;
uniform float velocity = 0.;
uniform float shipShift = 0.;

const int MAX_STEPS = 256;
const float MIN_DIST = 0.001;
const float FAR_DIST = 3.;
const float RAYMARCH_STEP = .9;

const float PI = 3.1416;
const float PI2 = PI*2.;

const float defaultBaseSize = .1;
const float defaultBaseSpacing = .3;
const vec3 bounds = vec3(150.0, .0, 2.);
const float cityShiftSpeed = 8.;

const float MAX_SPEED = 50.;

const bool NO_BUILDINGS = false;

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

mat4 getCubes(vec3 p) {
    if (NO_BUILDINGS) {
        return mat4(vec4(sdBox(p, vec3(.1, .1, .1)), p) * RAYMARCH_STEP, vec4(.1,.1,.1,0.), vec4(0.), vec4(0.));
    }
    float baseSpacing = defaultBaseSize + defaultBaseSpacing/2.;

    // float sID = floor(t);
    // float sN = N21(vec2(sID));
    // float sNnext = N21(vec2(sID+1.));

    // baseSpacing += 0.1*mix(sN, sNnext, fract(t));

    p.y += .3;

    float yStep = .1;

    vec3 l = bounds;
    vec3 rc1 = vec3(baseSpacing, yStep, 3.);
    vec3 id = round(p/rc1);
    vec3 q1 = p - rc1 * clamp(id, -l, l);

    float veloRate = smoothstep(0., MAX_SPEED, velocity);

    float tScaled = t / cityShiftSpeed;
    float elapsed = fract(tScaled);

    float n = getBuildingNoise(id, floor(tScaled));
    float n1 = getBuildingNoise(id, floor(tScaled + 1.));

    yStep += mix(.2 * n, .2 * n1, elapsed);

    rc1 = vec3(baseSpacing, yStep, 3.);
    id = round(p/rc1);
    q1 = p - rc1 * clamp(id, -l, l);

    q1.z += mix((n - .5) * .5, (n1 - .5) * .5, elapsed);
    q1.z += mix(sin(tScaled/3.+n*13.)*n*.2, sin(tScaled/3.+n1*13.)*n1*.2, elapsed);

    float rotSpeed = mix(300.*(n - .5), 300.* (n1 - .5), elapsed);
    float yOffset = id.y*sin(id.y)*mix(max(0., n - .88)*rotSpeed,max(0., n1 - .88)*rotSpeed, elapsed);
    yOffset *= veloRate;

    q1.xz *= rot2d(mix(yOffset + fract(n*322.33) + sin(tScaled+n*PI)*n*3., yOffset + fract(n1*322.33) + sin(tScaled+n1*PI)*n1*3., elapsed));

    float bw = .1 * min(1., mix(fract(n*123.33) + .4, fract(n1*123.33) + .4, elapsed));
    float bh = mix(getBuildingHeight(id, n), getBuildingHeight(id, n1), elapsed);

    // bh -= q1.y*q1.x;

    // bw *= 1. - q1.y * mix(min(.2, n), min(.2, n1), elapsed);

    q1.y -= bh - id.z/2.;
    float bw2 = bw*mix(max(.5, n), max(.5,n1), elapsed);
    return mat4(vec4(sdBox(q1, vec3(bw, bh, bw2)), q1) * RAYMARCH_STEP, vec4(bw,bh,bw2,0.), vec4(0.), vec4(0.));
}

float getSky(vec3 p) {
    return -(length(p) - 10.);
}

mat3 getDist(vec3 p) {
    float material = 0.;
    mat4 cubesm = getCubes(p - vec3(shipShift/5. * smoothstep(0., MAX_SPEED, velocity), 0., 0.))*.4;
    vec4 cubes = cubesm[0];
    float dB = cubes.x;
    float dS = getSky(p);
    float d = min(dB, dS);
    material = 1.;
    if (d == dS) {
        material = 2.;
        return mat3(vec3(d, material, 0.), p, cubesm[1].xyz);
    }
    return mat3(vec3(d, material, 0.), cubes.yzw, cubesm[1].xyz);
}

mat4 trace(vec3 ro, vec3 rd) {
    float dt, d;
    vec3 p;

    vec3 dist;
    mat3 dMat;

    for(int i = 0 ; i < MAX_STEPS ; i++) {
        p = ro + rd * dt;
        dMat = getDist(p);
        dist = dMat[0];
        dt += dist.x;
        if (abs(dist.x) < MIN_DIST || dist.x > FAR_DIST) {
            break;
        }
    }

    return mat4(vec4(dist.x, dt, dist.xy), vec4(dMat[1], 0.), vec4(dMat[2], 0.), vec4(0.));
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0.);
    float d = getDist(p)[0].x;
    vec3 n = d - vec3(
    getDist(p - e.xyy)[0].x,
    getDist(p - e.yxy)[0].x,
    getDist(p - e.yyx)[0].x
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

vec3 getCubeUV(vec3 p, vec3 normal, vec3 fsize) {
    vec2 cuv = vec2(0.);
    vec2 size = fsize.yz;
    if (normal.z != 0.) {
        // roof
        cuv.xy = vec2(p.x, p.y);
        size = fsize.xy;
        // size.y = size.x;
    }
    if (normal.x != 0.) {
        cuv.xy = vec2(p.y, p.z);
        size = fsize.yz;
    }
    if (normal.y != 0.) {
        cuv = vec2(p.x, p.z);
        size = fsize.xz;
    }

    cuv /= size*2.;

    cuv += vec2(.5, .5);

    float r = size.x / size.y;

    cuv -= vec2((r-1.)*.03, 0.);

    cuv.x *= r;

    return vec3(cuv, r);
}

vec3 getBuildingBacklitColor(vec2 uv, vec3 normal, vec3 size) {
    vec3 baseColor = vec3(.9 + sin(t*2.), cos(t), sin(t));
    baseColor *= max(.1, velocity/MAX_SPEED * .7);

    if (abs(normal.y) > 0.001) {
        return baseColor;
    }
    // float frame = step(size.z, uv.x);
    // return baseColor * frame;
    return max(vec3(.15), vec3(pow(.6/uv.y, 1. + (velocity/MAX_SPEED * 2.5))) * baseColor); //* step(sin(t), uv.y);
}

vec3 getBuildingTexture(vec2 uv, vec3 normal, vec3 size) {
    vec3 baseColor = vec3(.9 + sin(t*2.), cos(t), sin(t));
    baseColor *= max(.1, velocity/MAX_SPEED * .7);

    if (abs(normal.y) > 0.001) {
        return baseColor;
    }
    // float frame = step(abs(sin(t)), uv.y);
    // return baseColor * frame;
    return max(vec3(.15), vec3(pow(.6/uv.y, 1. + (velocity/MAX_SPEED * 2.5))) * baseColor); //* step(sin(t), uv.y);
}

vec3 getSkyTexture(vec3 p) {
    vec3 q1 = p;
    q1.yz *= rot2d(PI/2.5 + sin(t)*(PI/16.));
    // q1.xy *= rot2d(PI/2.5 + sin(t)*(PI/16.));
    p = q1;

    vec3 col = vec3(.0);
    // float x = acos(p.y/length(p));
    // float y = atan(p.z, p.x) / PI2 ;
    // vec2 uv = vec2(x, y);

    // uv = fract(uv*vec2(10., 31.4));

    float scale = .7;

    float n = N21(vec2(floor(t), 342.)) - .5;
    float n1 = N21(vec2(floor(t) + 1., 342.)) -.5;

    scale += .5 * mix(n, n1, fract(t));

    vec4 hex = hexCoords(p.xy*vec2(1., 1.0)*scale - vec2(shipShift*.5, shipShift*.2*sign(shipShift)));// + vec2(iTime, iTime*1.2));//*(1. + (sin(iTime)*.5 + .5)*5.));
    // col += step(hex.y, .02 * clamp(sin(t), 0., .1)*4.);

    // float t = t*3.;// + hex.z*hex.w*10.;

    float flick = smoothstep(.9, 1., sin(n + n1*4. + t + sin(t)/cos(t + sin(t*3.+t) + n)) * .5 + .5) * step(10., velocity);


    vec3 gridColor = mix(vec3(0., 1., 1.), mix(vec3(1.,0.,0.), vec3(0.,1.,0.), sin(t + n*10.)), cos(t/2. + n1*5.));
    // vec3 gridColor = vec3(0., 1., 1.);


    float matte = 1.;
    float mn = N21(abs(hex.ba) + floor(t)) - .5;
    float mn1 = N21(abs(hex.ba) + floor(t + 1.)) -.5;

    matte += 1. * mix(mn, mn1, fract(t));

    col += pow(.03/hex.y, 1.7) * gridColor;
    // col += vec3(N21(hex.ba + 100.)*gridColor)*matte;
    col += matte * gridColor;

    col *= flick;

    // return vec3(uv.x, uv.y, 0.);

    return col;
}

vec3 getAlbedoByMaterial(float material, vec3 p, vec3 normal, mat4 trm) {
    vec3 albedo = vec3(1.);
    if ( material == 2.) {
        albedo = getSkyTexture(p);
        } else {
        vec3 backLit = getCubeUV(p, normal, trm[2].xxy);
        vec3 backLitColor = getBuildingBacklitColor(backLit.yx + vec2(.0, 0.5), normal, trm[2].xyz);
        // vec3 uv = getCubeUV(p, normal, trm[2].xyz);
        // vec3 textureColor = getBuildingTexture(uv.yx, normal, trm[2].xyz);
        albedo = backLitColor;
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
    float zoom = .6 + sin(velocity/MAX_SPEED * PI/2.)*.1;  //pow(velocity / 80., 3.);// + sin(t)*.3;

    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), f));
    vec3 u = cross(f, r);
    vec3 c = ro + f * zoom;
    vec3 i = c + uv.x*r + uv.y*u;
    vec3 rd = normalize(i - ro);

    mat4 trm = trace(ro, rd);
    vec4 tr = trm[0];
    float materialID = tr.a;
    float distanceTo = tr.y;

    vec3 lightPos = LightPosition;// * vec3(0., 2., sin(t*10.)*-2.);//vec3(1. + cos(TIME*0.)*3., 2. + sin(TIME*3.*0.), -1.5);

    if (tr.x < MIN_DIST) {
        vec3 p = ro + rd * distanceTo;
        col = vec3(1.);
        vec3 normal = getNormalByMaterial(materialID, p);
        vec3 albedo = getAlbedoByMaterial(materialID, trm[1].xyz, normal, trm);
        vec3 diffuse = getLightColor(p, normal, lightPos);
        vec3 specular = vec3(0.);
        // vec3 specular = getSpecularColor(p, normal, lightPos, ro);
        float ambient = .1;
        float fade = 1.;
        if (materialID == 1.) {
            fade -= abs(p.z)/5.;
        }
        col = clamp((ambient + diffuse + specular) * albedo, 0., 1.) * fade;
    }


    // col += DrawPoint(ro, rd, vec3(sin(TIME)*.2, cos(TIME)*.2, sin(TIME*10.)*.9));// * vec3(1., 0., 0.);
    // col += vec3(step(.2, uv.y));
    ALBEDO.rgb = col;// * vec3(sin(t), sin(t*2. - uv.x), sin(t*2. + uv.x));
    if (materialID == 1.) {
        ALPHA = smoothstep(0.,.1, col.r + col.g + col.b);
        } else if (materialID == 2.) {
        // ALPHA = smoothstep(0.,.4, col.r + col.g + col.b);
        ALPHA = abs(sin(t/4. + uv.y*.8) + cos(t/2. + uv.x*.3)) * step(10., velocity);//smoothstep(0.,.4, col.r + col.g + col.b);
    }
    // ALPHA = col.g;
}