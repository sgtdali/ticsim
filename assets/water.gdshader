shader_type canvas_item;

uniform float wave_speed : hint_range(0.1, 5.0) = 1.5;
uniform float wave_amplitude : hint_range(0.0, 0.02) = 0.004;
uniform float shimmer_strength : hint_range(0.0, 0.2) = 0.06;

void fragment() {
	vec2 uv = UV;

	// Önce orijinal pikseli oku, su mu değil mi anla
	vec4 original = texture(TEXTURE, uv);

	// Su tespiti: mavi/cyan ağırlıklı piksel
	float is_water = step(0.45, original.b)
	               * step(original.r, 0.55)
	               * step(0.0, original.a - 0.1);

	// Dalga distorsiyonu — sadece su piksellerine
	vec2 waved_uv = uv;
	waved_uv.x += sin(uv.y * 28.0 + TIME * wave_speed) * wave_amplitude * is_water;
	waved_uv.y += cos(uv.x * 22.0 + TIME * wave_speed * 0.75) * wave_amplitude * is_water;

	vec4 distorted = texture(TEXTURE, waved_uv);

	// Işık titremesi (shimmer)
	float shimmer = sin(uv.x * 60.0 + uv.y * 40.0 + TIME * 4.0) * shimmer_strength + (1.0 - shimmer_strength);

	vec4 water_pixel = distorted * vec4(shimmer, shimmer, 1.0, 1.0);

	COLOR = mix(original, water_pixel, is_water);
}
