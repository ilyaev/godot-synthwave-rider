shader_type particles;
render_mode keep_data;

uniform sampler2D noise;
uniform float size;

const float rows = 10.;
const float defaultWidth = 8.;
const float rowSpacing = defaultWidth * 4.;
const float colSpacing = defaultWidth * 1.5;

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

    float depth = size / rows;
    float width = rows;

    float zi = floor(float(index) / width);
    float xi = float(index) - (zi*width);

    float h =  0.;

    float len = 1.;

    float x = float(xi) * (len + colSpacing);
    float z = float(zi) * (len - rowSpacing);

    // horizontal shift
    // x += sin(zi*4. + t*3. + xi)*3.;

    // noise shift
    // z += (texture(noise, vec2(xi,zi+1.)/10. + vec2(t/20.,t/40.)).r - .5) * 45.;
    // x += (texture(noise, vec2(xi+543.,zi+12.)/10. + vec2(t/10.,t/20.)).r - .5) * 45.;

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

    vec2 id = vr[1].xy;

    float h = getBuildingHeight(vr[1].xy, TIME);

    // position
    TRANSFORM[3].xyz = vr[0];
    TRANSFORM[3].y += TRANSFORM[1].y / 2.;
    TRANSFORM[3].x -= (colSpacing * rows) / 2. + defaultWidth / 2.;


    // scale
    mat3 scale = mat3(vec3(defaultWidth,0.,0.), vec3(0.,h,0.), vec3(0.,0.,defaultWidth/2.));


    // rotation
    mat3 rotation = rotateY(sin(TIME * (id.x - rows/2.) + TIME/2.) + id.y);
    // mat3 rotation = rotate3d(vec3(TIME + vr[1].x, TIME/2. + vr[1].x,TIME*2. + vr[1].x/2.));

    mat3 transform = rotation;
    transform *= scale;

    TRANSFORM[0].xyz = transform[0].xyz;
    TRANSFORM[1].xyz = transform[1].xyz;
    TRANSFORM[2].xyz = transform[2].xyz;


    COLOR.rgb = vec3(vr[1].xy, h);
}

void fragment() {

}