shader_type canvas_item;

uniform float pixel_size = 4.0;
uniform float grain_strength = 0.16;
uniform float micro_grain = 0.08;
uniform float macro_variation = 0.14;
uniform float edge_shading = 0.13;
uniform float center_brightness = 0.04;
uniform float grime_intensity = 0.10;
uniform float horizontal_wear = 0.035;

float hash21(vec2 p) {
	p = fract(p * vec2(119.13, 383.41));
	p += dot(p, p + 31.19);
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
		value_noise(p * 0.18 + vec2(4.0, 8.0)),
		value_noise(p * 0.18 + vec2(10.0, 1.0))
	);
	p += (warp - 0.5) * 4.0;

	float blotch = value_noise(rot(0.3) * p * 0.05 + vec2(8.0, 13.0));
	float broad = value_noise(rot(0.9) * p * 0.16);
	float mid = value_noise(rot(1.6) * p * 0.52 + vec2(12.0, 4.0));
	float micro = value_noise(rot(0.2) * p * 2.4 + vec2(3.0, 27.0));
	float streak = value_noise(vec2(p.x * 0.10, p.y * 1.8) + vec2(21.0, 5.0));

	float n = broad * 0.42 + mid * 0.36 + micro * 0.22;
	float dirt = smoothstep(0.22, 0.84, blotch);
	float grain = (micro - 0.5) * micro_grain;
	float wear = (streak - 0.5) * horizontal_wear;

	vec3 dark = vec3(0xA5, 0x98, 0x78) / 255.0;
	vec3 mid_color = vec3(0xB9, 0xAE, 0x92) / 255.0;
	vec3 light = vec3(0xC7, 0xBD, 0xA0) / 255.0;

	vec3 picked = mix(dark, mid_color, smoothstep(0.20, 0.78, n));
	picked = mix(picked, light, smoothstep(0.70, 1.0, n) * 0.18);

	float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge = 1.0 - smoothstep(0.0, 0.18, edge_distance);
	float center = smoothstep(0.10, 0.50, edge_distance);
	float shade = 1.0 - edge * edge_shading - dirt * grime_intensity;
	float lift = center * center_brightness + wear + grain + (blotch - 0.5) * macro_variation * 0.12;

	vec3 base = vec3(0xB9, 0xAE, 0x92) / 255.0;
	vec3 material = mix(base, picked, grain_strength);
	material *= shade;
	material += lift;
	COLOR = vec4(clamp(material, 0.0, 1.0), 1.0);
}
