shader_type particles;

uniform sampler2D noise;
uniform float size;

const float rows = 10.;
const float defaultWidth = 8.;


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

    TRANSFORM[3].xyz = vr[0];
    TRANSFORM[0].x = defaultWidth;
    TRANSFORM[1].y = h;//defaultWidth * 3.5;// + vr[1].x*13.;
    TRANSFORM[2].z = defaultWidth;

    TRANSFORM[3].y += TRANSFORM[1].y / 2.;
    // TRANSFORM[3].x += (defaultWidth*1.2) / 2.;
    TRANSFORM[3].x -= ((defaultWidth * rows) * 1.1) / 2.;// - (defaultWidth*1.2) / 2.;




    COLOR.rgb = vec3(vr[1].xy, TRANSFORM[1].y); //smoothstep(0.5, 1.0, (TRANSFORM[3].y+0.5)*1.2); //abs(sin(TIME*3. + float(INDEX)/8.));

//}
}

void fragment() {

}