shader_type canvas_item;

uniform float pixel_size = 3.0;
uniform float grain_strength = 0.45;
uniform float micro_grain = 0.14;
uniform float macro_variation = 0.32;
uniform float edge_shading = 0.30;
uniform float center_brightness = 0.12;
uniform float grime_intensity = 0.12;
uniform float horizontal_wear = 0.07;

float hash21(vec2 p) {
	p = fract(p * vec2(127.17, 311.79));
	p += dot(p, p + 37.23);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

mat2 rot(float a) {
	float s = sin(a);
	float c = cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

void fragment() {
	vec2 p = FRAGCOORD.xy / max(pixel_size, 1.0);

	vec2 warp = vec2(
		value_noise(p * 0.24 + vec2(2.0, 9.0)),
		value_noise(p * 0.24 + vec2(11.0, 4.0))
	);
	p += (warp - 0.5) * 8.0;

	float blotch = value_noise(rot(0.25) * p * 0.06 + vec2(6.0, 18.0));
	float broad = value_noise(rot(0.0) * p * 0.16);
	float mid = value_noise(rot(1.1) * p * 0.52 + vec2(17.0, 9.0));
	float fine = value_noise(rot(2.3) * p * 1.8 + vec2(5.0, 31.0));
	float micro = value_noise(rot(0.6) * p * 4.2 + vec2(23.0, 13.0));
	float streak = value_noise(vec2(p.x * 0.12, p.y * 2.2) + vec2(7.0, 33.0));

	float n = broad * 0.22 + mid * 0.24 + fine * 0.28 + micro * 0.26;
	float tarnish = smoothstep(0.22, 0.82, blotch);
	float grain = (micro - 0.5) * micro_grain + (fine - 0.5) * micro_grain * 0.45;
	float wear = (streak - 0.5) * horizontal_wear;

	vec3 dark = vec3(0x4A, 0x3A, 0x24) / 255.0;
	vec3 mid_color = vec3(0x57, 0x45, 0x2C) / 255.0;
	vec3 light = vec3(0x62, 0x4F, 0x35) / 255.0;

	vec3 picked = mix(dark, mid_color, smoothstep(0.25, 0.75, n));
	picked = mix(picked, light, smoothstep(0.62, 0.94, n) * 0.34);

	float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge = 1.0 - smoothstep(0.0, 0.20, edge_distance);
	float center = smoothstep(0.08, 0.48, edge_distance);
	float corners = 0.0;
	corners += 1.0 - smoothstep(0.0, 0.32, distance(UV, vec2(0.0, 0.0)));
	corners += 1.0 - smoothstep(0.0, 0.32, distance(UV, vec2(1.0, 0.0)));
	corners += 1.0 - smoothstep(0.0, 0.32, distance(UV, vec2(0.0, 1.0)));
	corners += 1.0 - smoothstep(0.0, 0.32, distance(UV, vec2(1.0, 1.0)));
	corners = clamp(corners, 0.0, 1.0);

	float shade = 1.0 - edge * edge_shading - corners * edge_shading * 0.28 - tarnish * grime_intensity;
	float polish = center * center_brightness + wear + grain + (blotch - 0.5) * macro_variation * 0.16;

	vec3 base = vec3(0x57, 0x45, 0x2C) / 255.0;
	vec3 material = mix(base, picked, grain_strength);
	material *= shade;
	material += polish;
	COLOR = vec4(clamp(material, 0.0, 1.0), 1.0);
}
