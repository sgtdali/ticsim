shader_type canvas_item;

uniform float pixel_size = 5.0;
uniform float grain_strength = 0.18;
uniform float micro_grain = 0.10;
uniform float medium_variation = 0.08;
uniform float macro_variation = 0.055;
uniform float edge_shading = 0.14;
uniform float center_brightness = 0.035;
uniform float grime_intensity = 0.08;
uniform float horizontal_wear = 0.025;
uniform float warp_strength = 0.015;

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

void fragment() {
	vec2 p = FRAGCOORD.xy / max(pixel_size, 1.0);

	vec2 warp = vec2(
		value_noise(p * 0.18 + vec2(2.0, 9.0)),
		value_noise(p * 0.18 + vec2(11.0, 4.0))
	);
	p += (warp - 0.5) * warp_strength;

	float macro = value_noise(p * 0.045 + vec2(4.0, 12.0));
	float medium = value_noise(p * 0.34 + vec2(17.0, 9.0));
	float micro = value_noise(p * 2.8 + vec2(23.0, 13.0));
	float wear = value_noise(vec2(p.x * 0.07, p.y * 2.0) + vec2(31.0, 2.0));

	vec3 base = vec3(0x15, 0x15, 0x12) / 255.0;
	vec3 secondary = vec3(0x23, 0x20, 0x19) / 255.0;

	float material_mix = 0.22 + (medium - 0.5) * medium_variation + (macro - 0.5) * macro_variation;
	vec3 material = mix(base, secondary, clamp(material_mix, 0.0, 1.0));

	float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge = 1.0 - smoothstep(0.0, 0.16, edge_distance);
	float center = smoothstep(0.10, 0.48, edge_distance);

	float darken = edge * edge_shading + (1.0 - macro) * grime_intensity * 0.45;
	float lift = center * center_brightness;
	lift += (micro - 0.5) * micro_grain;
	lift += (wear - 0.5) * horizontal_wear;

	material *= 1.0 - darken;
	material += lift * grain_strength;

	COLOR = vec4(clamp(material, 0.0, 1.0), 1.0);
}
