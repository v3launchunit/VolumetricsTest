shader_type canvas_item;

render_mode unshaded;

uniform float temperature: hint_range(0.0, 1.0, 0.01);
uniform float heat_scale_max: hint_range(0.0, 32.0, 0.1) = 8;
uniform float heat_speed: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform sampler2D heat_noise: hint_default_white, filter_linear, repeat_enable;
uniform sampler2D screen: hint_screen_texture, filter_nearest;

void fragment() {
	COLOR = texture(
			screen,
			SCREEN_UV + (
					texture(heat_noise, SCREEN_UV + TIME * vec2(0.0, heat_speed)).rg
					- vec2(0.5)
			)
			* SCREEN_PIXEL_SIZE
			* heat_scale_max
			* temperature
			* COLOR.a
			* 2.0
	);
}
