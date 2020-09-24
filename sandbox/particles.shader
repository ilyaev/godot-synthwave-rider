shader_type particles;

uniform sampler2D noise;
uniform float size;

const float rows = 10.;
const float defaultWidth = 8.;

mat4 rotateX(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat4(vec4(0.,0.,1.,0.), vec4(cs, sn, 0.,0.), vec4(-1.*sn, cs, 0.,0.), vec4(0.,0.,0.,1.));
}

mat4 rotateY(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat4(vec4(-1.*sn,cs,0.,0.), vec4(0.,0.,1.,0.), vec4(cs,sn, 0.,0.), vec4(0.,0.,0.,1.));
}

mat4 rotateYS(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat4(vec4(cs,0.,sn, 0.), vec4(0., 1., 0., 0.), vec4(-sn, 0., cs, 0.), vec4(0.,0.,0.,1.));
}

mat3 rotateYS3(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat3(vec3(cs,0.,sn), vec3(0., 1., 0.), vec3(-sn, 0., cs));
}

mat4 rotateZ(float angle) {
    float cs = cos(angle);
    float sn = sin(angle);
    return mat4(vec4(cs,sn,0.,0.), vec4(-sn,cs,0.,0.), vec4(0.,0., 1.,0.), vec4(0.,0.,0.,1.));
}

mat4 rotate3d(vec3 rotation) {
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
    float z = float(zi) * (len + space);

    vec3 offset = vec3(0.) - vec3(width * (len + space) / 2.);

    vec3 c = vec3(x,h,z);// + offset + vec3(0., -offset.y, 0.);
    return mat3(c,vec3(xi, zi, h),c);
}

float getBuildingHeight(vec2 id, float t) {
    return 50. - abs(id.x - rows/2.) * 7. + sin(id.x + t + id.y*2.)*14.;
}

void vertex() {

    mat3 vr = coords(INDEX, TIME);

    float h = getBuildingHeight(vr[1].xy, TIME);

    // position



    // scale
    // TRANSFORM[0].x = defaultWidth;
    // TRANSFORM[1].y = h;
    // TRANSFORM[2].z = defaultWidth;


    // position
    // TRANSFORM[3].y += TRANSFORM[1].y / 2.;
    // TRANSFORM[3].x -= ((defaultWidth * rows) * 1.1) / 2.;

    float rh = TRANSFORM[1].y;


    // mat4 scale = mat4(vec4(defaultWidth, 0., 0., 0.),vec4(0., h, 0., 0.),vec4(0., 0., defaultWidth, 0.),vec4(0., 0., 0., 1.));
    // mat4 rotation = rotate3d(vec3(0., 0., 0.));

    // TRANSFORM *= scale;
    // TRANSFORM *= rotation;

    // mat4 rotation = rotateYS(TIME + vr[1].x);
    // mat4 rotation = rotateY(TIME + vr[1].x);
    // mat4 nt = matrixCompMult(TRANSFORM,rotation);
    // mat4 nt = TRANSFORM * rotation;

    mat3 r3 = rotateYS3(TIME*2.);
    mat3 rm = mat3(TRANSFORM[0].xyz, TRANSFORM[1].xyz, TRANSFORM[2].xyz);
    mat3 scale = mat3(vec3(defaultWidth,0.,0.), vec3(0.,h,0.), vec3(0.,0.,defaultWidth));
    mat3 nt = r3 * scale;

    TRANSFORM[0].xyz = nt[0].xyz;
    TRANSFORM[1].xyz = nt[1].xyz;
    TRANSFORM[2].xyz = nt[2].xyz;


    TRANSFORM[3].xyz = vec3(sin(TIME)*5.,0.,cos(TIME)*5.);


    // TRANSFORM[0].x = defaultWidth;
    // TRANSFORM[1].y *= 10.;
    // TRANSFORM[2].z = defaultWidth;


    COLOR.rgb = vec3(vr[1].xy, rh);

//}
}

void fragment() {

}