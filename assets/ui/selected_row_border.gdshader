shader_type canvas_item;

uniform vec4 near_color : source_color = vec4(0.482353, 0.321569, 0.164706, 1.0);
uniform vec4 far_color : source_color = vec4(0.333333, 0.231373, 0.129412, 1.0);
uniform int edge_side = 0; // 0 top, 1 bottom, 2 left, 3 right
uniform float noise_strength = 0.22;

float hash21(vec2 p) {
	p = fract(p * vec2(173.31, 421.17));
	p += dot(p, p + 29.71);
	return fract(p.x * p.y);
}

void fragment() {
	float inward = UV.y;
	if (edge_side == 1) {
		inward = 1.0 - UV.y;
	} else if (edge_side == 2) {
		inward = UV.x;
	} else if (edge_side == 3) {
		inward = 1.0 - UV.x;
	}

	float noise = hash21(floor(FRAGCOORD.xy));
	float near_amount = smoothstep(0.36, 1.0, inward);
	near_amount = clamp(near_amount + (noise - 0.5) * noise_strength, 0.0, 1.0);

	COLOR = mix(far_color, near_color, near_amount);
}
