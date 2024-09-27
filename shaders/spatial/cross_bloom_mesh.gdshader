shader_type spatial;

render_mode blend_add, unshaded;

uniform float intensity : hint_range(0.0, 16.0, 0.1) = 1.0;
uniform float threshold : hint_range(0.0, 4.0, 0.01) = 0.9;
uniform int spread : hint_range(0, 128, 1) = 8;
uniform float scale : hint_range(0.0, 4.0, 0.1) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

global uniform ivec2 screen_size;

bool is_above_threshold(vec3 in_col) {
	return in_col.x >= threshold || in_col.y >= threshold || in_col.z >= threshold;
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
	POSITION.z = mix(POSITION.z, 0, 0.99);
}

void fragment() {
	vec3 col = max(texture(screen_texture, SCREEN_UV).xyz - threshold, 0);

	for (int i = 1; i < spread; i++) {
		float x_dist = float(i) * pow(2, scale) / float(screen_size.x);
		float y_dist = float(i) * pow(2, scale) / float(screen_size.y);
		vec3 col_up_left = clamp(textureLod(screen_texture, SCREEN_UV + vec2(-x_dist, y_dist), scale).xyz - threshold, vec3(0), vec3(8));
		vec3 col_up_right = clamp(textureLod(screen_texture, SCREEN_UV + vec2(x_dist, y_dist), scale).xyz - threshold, vec3(0), vec3(8));
		vec3 col_down_left = clamp(textureLod(screen_texture, SCREEN_UV + vec2(-x_dist, -y_dist), scale).xyz - threshold, vec3(0), vec3(8));
		vec3 col_down_right = clamp(textureLod(screen_texture, SCREEN_UV + vec2(x_dist, -y_dist), scale).xyz - threshold, vec3(0), vec3(8));

		col += col_up_left / (float(i) * 4.0);
		col += col_up_right / (float(i) * 4.0);
		col += col_down_left / (float(i) * 4.0);
		col += col_down_right / (float(i) * 4.0);
	}

	ALBEDO.xyz = col * intensity / float(spread);
}
