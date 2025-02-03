shader_type canvas_item;

render_mode blend_add;

uniform float intensity : hint_range(0.0, 16.0, 0.1) = 1.0;
uniform float threshold : hint_range(0.0, 4.0, 0.01) = 0.9;
uniform int spread : hint_range(0, 128, 1) = 8;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

global uniform ivec2 screen_size;

#define MAX_BRIGHTNESS 5.0
#define BLOOM_SAMPLE(dir) clamp(texture(screen_texture, SCREEN_UV + dir).rgb - threshold, 0.0, MAX_BRIGHTNESS)

bool is_above_threshold(vec3 in_col) {
	return in_col.x >= threshold || in_col.y >= threshold || in_col.z >= threshold;
}

void fragment() {
	vec3 col = max(texture(screen_texture, SCREEN_UV).xyz - threshold, 0);
	float inv_spread = 1.0/float(spread);

	for (int i = 1; i < spread; i++) {
		float x_dist = float(i) * SCREEN_PIXEL_SIZE.x; // float(screen_size.x);
		float y_dist = float(i) * SCREEN_PIXEL_SIZE.y; // float(screen_size.y);
		vec3 col_up_left = BLOOM_SAMPLE(vec2(-x_dist, y_dist));
		vec3 col_up_right = BLOOM_SAMPLE(vec2(x_dist, y_dist));
		vec3 col_down_left = BLOOM_SAMPLE(vec2(-x_dist, -y_dist));
		vec3 col_down_right = BLOOM_SAMPLE(vec2(x_dist, -y_dist));

		float str = mix(0.25 * inv_spread, 0.0, float(i) * inv_spread);

		col += col_up_left * str;// / (float(i) * 4.0);
		col += col_up_right * str;// / (float(i) * 4.0);
		col += col_down_left * str;// / (float(i) * 4.0);
		col += col_down_right * str;// / (float(i) * 4.0);
	}

	COLOR.xyz = col * intensity;
}
