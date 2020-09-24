shader_type particles;
render_mode keep_data;

uniform sampler2D noise;
uniform float size;

const float rows = 10.;
const float defaultWidth = 8.;
const float rowSpacing = defaultWidth * 4.;

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

    float space = defaultWidth * 1.1;

    float h =  0.;

    float len = 1.;

    float x = float(xi) * (len + space);// + sin(t)*20.;// + sin(zi*4. + t*3. + xi)*3.;
    float z = float(zi) * (len - rowSpacing);

    vec3 offset = vec3(0.) - vec3(width * (len + space) / 2.);

    vec3 c = vec3(x,h,z);
    return mat3(c,vec3(xi, zi, h),c);
}

float getBuildingHeight(vec2 id, float t) {
    return 50. - abs(id.x - rows/2.) * 7.;// + sin(id.x + t + id.y*2.)*14.;
}

void vertex() {

    mat3 vr = coords(INDEX, TIME);

    float h = getBuildingHeight(vr[1].xy, TIME);

    // position
    TRANSFORM[3].xyz = vr[0];
    TRANSFORM[3].y += TRANSFORM[1].y / 2.;
    TRANSFORM[3].x -= ((defaultWidth * rows) * 1.1) / 2.;


    // scale
    mat3 scale = mat3(vec3(defaultWidth,0.,0.), vec3(0.,h,0.), vec3(0.,0.,defaultWidth));


    // rotation
    mat3 rotation = rotateY(TIME + vr[1].x);
    // mat3 rotation = rotate3d(vec3(TIME + vr[1].x, TIME/2. + vr[1].x,TIME*2. + vr[1].x/2.));


    mat3 transform = scale;

    TRANSFORM[0].xyz = transform[0].xyz;
    TRANSFORM[1].xyz = transform[1].xyz;
    TRANSFORM[2].xyz = transform[2].xyz;


    COLOR.rgb = vec3(vr[1].xy, h);
}

void fragment() {

}