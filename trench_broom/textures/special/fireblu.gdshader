shader_type spatial;

render_mode unshaded;

uniform vec2 red_scroll = vec2(0.1);
uniform vec2 blu_scroll = vec2(-0.1);

uniform vec2 uv_scale = vec2(1.0);

uniform sampler2D tex: source_color, filter_linear, repeat_enable;

void vertex() {
	UV = UV * uv_scale * 0.0625 * 0.0625;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 disp_r = texture(tex, SCREEN_UV - vec2(0.0, TIME * 0.1)).xy * 0.1;
	vec2 disp_b = texture(tex, SCREEN_UV.yx - vec2(TIME * 0.1, 0.0)).xy * 0.1;
	float r = texture(tex, disp_r + SCREEN_UV + TIME * red_scroll).r;
	float b = texture(tex, disp_b + SCREEN_UV.yx + TIME * blu_scroll).b;

	ALBEDO = vec3(r, 0.0, b);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
