shader_type spatial;


uniform float pos;
uniform vec2 size;
uniform sampler2D noise;
uniform sampler2D road;

float N21(vec2 p) {
	return fract(sin(p.x*223.32+p.y*5677.)*4332.23);
}

void vertex() {
	float t = pos * ((size - vec2(1., 1.))/size).y;
	float h = 0.0;

	h += 1.7 * sin(VERTEX.z - t) + fract((VERTEX.z - t) / 2.);
	h += cos(VERTEX.x) * sin(VERTEX.z - t);

	float maxH = 35.;
	maxH *= sin(TIME*2. + VERTEX.x*13.);

	h += max(0., texture(noise, (UV + vec2(0, t)) *3.).r * maxH - (maxH * .55));

	h *= texture(road, UV).r;

	VERTEX.y += max(h, 0.);
}

void fragment() {
	vec2 uv = fract(UV * size);
	ALBEDO.gb = vec2(0.);
	ALBEDO.r = uv.x * uv.y;// * (step(UV.x, .47) + step(.53, UV.x));
	// ALBEDO.r = step(.9, uv.x) + step(.9, uv.y);
	// ALBEDO.r = pow(1./length(uv - .5) * .05, 2.2);
	// float d = (VERTEX.z + size.y / 2.) / size.y;
	// ALBEDO.r *= d;
	// if (d < .05) {
		// 	ALPHA = .0
	// }
	// if (VERTEX.z > 30.) {
		// 	ALPHA = 1. - VERTEX.y / 20.;
	// }
}