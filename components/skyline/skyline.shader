shader_type particles;
render_mode keep_data;

uniform sampler2D noise;
uniform float seed_building_height : hint_range(1., 100.) = 6.;
uniform float shipShift = 0.;
uniform float velocity = 0.;
uniform float noiseSeed = 4.;

const float rows = 10.;
const float defaultWidth = 8.;
const float rowSpacing = defaultWidth * 4.;
const float colSpacing = defaultWidth * 1.3;

const float PI = 3.1415;

float n21(vec2 p) {
    return fract(sin(p.x * 132.33 + p.y*1433.43) * 55332.33);
}

mat3 rotateX(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat3(vec3(1.,0.,0.), vec3(0., cs, -sn), vec3(0., sn, cs));
}

mat3 rotateY(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat3(vec3(cs,0.,sn), vec3(0., 1., 0.), vec3(-sn, 0., cs));
}

mat3 rotateZ(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat3(vec3(cs,-sn,0.), vec3(sn, cs, 0.), vec3(0., 0., 1.));
}

mat3 rotate3d(vec3 rotation) {
    return rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);
}


mat3 coords(int index, float t) {

    float width = rows;

    float zi = floor(float(index) / width);
    float xi = float(index) - (zi*width);

    float h =  0.;

    float len = 1.;

    float oddity = 1. - mod(zi, 2.)*2.;

    float x = float(xi) * (len + colSpacing) - (zi * (defaultWidth/2.) * oddity);
    float z = float(zi) * (len - rowSpacing);

    // horizontal shift
    // x += sin(zi*4. + t*3. + xi)*3.;

    // noise shift
    float nt = t/100.;
    z += (texture(noise, vec2(xi,zi+1.)/80. + vec2(nt, 0.)).r - .5) * 45.;
    x += (texture(noise, vec2(xi+543.,zi+12.)/80. + vec2(nt, 0.)).r - .5) * 45.;

    vec3 offset = vec3(0.) - vec3(width * (len + colSpacing) / 2.);

    vec3 c = vec3(x,h,z);
    return mat3(c,vec3(xi, zi, h),c);
}

float getBuildingHeight(vec2 id, float t) {
    float h = 50. - abs(id.x - rows/2.) * 7.;

    // h += sin(id.x + t/2. + id.y*2.)*14.;

    return h;
}

void vertex() {

    mat3 vr = coords(INDEX, TIME);

    float depth = defaultWidth/2.;

    vec2 id = vr[1].xy;

    float n = n21(id + vec2(100., noiseSeed));
    float t = (TIME + n)/2.;

    float h = getBuildingHeight(vr[1].xy, TIME);
    h += n * 15.;


    // vertical wobble
    // float h1 = n21(id + vec2(100. + floor(t), 1.));
    // float h2 = n21(id + vec2(101. + floor(t), 1.));
    // h += (mix(h1, h2, fract(t)) - 0.5) * 20.;




    // position
    TRANSFORM[3].xyz = vr[0];
    TRANSFORM[3].y += TRANSFORM[1].y / 2.;
    TRANSFORM[3].x -= (colSpacing * rows) / 2. + defaultWidth / 2.;


    // t = TIME + fract(n*1234.322);
    // float pZ = n21(id + vec2(200. + floor(t), 0.));
    // float pZNext = n21(id + vec2(201. + floor(t), 0.));
    // TRANSFORM[3].z += mix(pZ*20. - 10., pZNext * 20. - 10., fract(t));

    TRANSFORM[3].z -= abs(id.x - 5.)*2.;
    TRANSFORM[3].x += (fract(n*123.456) - .5) * 10.;
    TRANSFORM[3].z += (fract(n*3232.456) - .5) * 20.;


    // scale
    mat3 scale = mat3(vec3(defaultWidth,0.,0.), vec3(0.,h,0.), vec3(0.,0.,depth));


    // rotation
    // t = TIME + n*2.;
    // t /= max(1., fract(n*123.)*3.);
    // float rY = n21(id + vec2(100. + floor(t), 0.));
    // float rYNext = n21(id + vec2(101. + floor(t), 0.));
    // mat3 rotation = rotateY(mix(rY * PI, rYNext * PI, fract(t)));
    // mat3 rotation = rotateY(sin(TIME * (id.x - rows/2.) + TIME/2.) + id.y);
    // mat3 rotation = rotate3d(vec3(TIME + vr[1].x, TIME/2. + vr[1].x,TIME*2. + vr[1].x/2.));

    float rYbase = (id.x - rows/2.)/(rows*1.8);
    rYbase += (fract(n*23543.2) - .2) * step(abs(id.x), 2.);

    float rotationNoise = (texture(noise, vec2(id.x + 43., id.y + 112.) / 10. + vec2(TIME/100., 0.)).r - .5) * 2.;
    mat3 rotation = rotateY((rYbase - rotationNoise) * PI);


    mat3 transform = rotation;
    transform *= scale;

    TRANSFORM[0].xyz = transform[0].xyz;
    TRANSFORM[1].xyz = transform[1].xyz;
    TRANSFORM[2].xyz = transform[2].xyz;


    // approach
    // TRANSFORM[3].z += fract(TIME/2.) * 10.;


    // parallax
    TRANSFORM[3].x -= shipShift * 4.;//12.;


    // COLOR.rgb = vec3(vr[1].xy, h);
    CUSTOM.rgba = vec4(vr[1].xy, h, defaultWidth);
    COLOR.r = depth;
}

void fragment() {

}