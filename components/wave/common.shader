float N21(vec2 p) {
    return fract(sin(p.x*mountain_seed.x+p.y*mountain_seed.y)*mountain_seed.z);
}

float SmoothNoise(vec2 uv) {
    vec2 lv = smoothstep(0., 1., fract(uv));
    vec2 id = floor(uv);

    float bl = N21(id);
    float br = N21(id + vec2(1.,0.));
    float b = mix(bl, br, lv.x);

    float tl = N21(id + vec2(0.,1.));
    float tr = N21(id + vec2(1.,1.));
    float t = mix(tl, tr, lv.x);

    float n = mix(b, t, lv.y);
    return n;
}

float Noise(vec2 uv, int level) {
    float n = 0.;
    float d = 1.;
    if (level > 0) {
        n += SmoothNoise(uv * 4.);
    }
    if (level > 1) {
        n += SmoothNoise(uv * 8.) * .5;
        d += .5;
    }
    if (level > 2) {
        n += SmoothNoise(uv * 16.) * .25;
        d += .25;
    }
    if (level > 3) {
        n += SmoothNoise(uv * 32.) * .125;
        d += .125;
    }
    if (level > 4) {
        n += SmoothNoise(uv * 64.) * .025;
        d += .0625;
    }
    return n / d;
}