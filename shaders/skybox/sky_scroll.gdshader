shader_type sky;

uniform vec3 base_color: source_color = vec3(0.5);

// sky (upper half of background) uniforms
group_uniforms sky;
uniform float sky_distance: hint_range(0.0, 32.0, 0.1) = 8.0;
uniform vec4 sky_color: source_color = vec4(1.0);
uniform sampler2D texture_sky: source_color, filter_nearest, hint_default_white;
uniform vec2 uv_sky_scale = vec2(0.125);
uniform vec2 uv_sky_scroll_speed = vec2(0.05);

// cloud layer 1 uniforms
group_uniforms sky_clouds_1;
uniform vec4 sky_clouds_1_color: source_color = vec4(1.0);
uniform sampler2D texture_sky_clouds_1: source_color, filter_nearest, hint_default_transparent;
uniform vec2 uv_sky_clouds_1_scale = vec2(0.125);
uniform vec2 uv_sky_clouds_1_scroll_speed = vec2(0.05);

// surface (lower half of background) uniforms
group_uniforms surface;
uniform float surface_distance: hint_range(0.0, 32.0, 0.1) = 32.0;
uniform vec4 surface_color: source_color = vec4(vec3(0.0), 1.0);
uniform sampler2D texture_surface: source_color, filter_nearest, hint_default_white;
uniform vec2 uv_surface_scale = vec2(0.125);
uniform vec2 uv_surface_scroll_speed = vec2(0.0);

vec3 get_sky_color(vec3 eye_dir, float time) {
	vec3 color;

	if (eye_dir.y > 0.0) {
			vec2 sky_uv = eye_dir.xz * inversesqrt(eye_dir.y) * uv_sky_scale;
			vec4 sky_tex = texture(texture_sky, sky_uv + time * uv_sky_scale * uv_sky_scroll_speed);
			vec4 sky_clouds_1_tex = texture(texture_sky_clouds_1, sky_uv + time * uv_sky_clouds_1_scale * uv_sky_clouds_1_scroll_speed);
			color = mix(
					sky_tex.rgb * sky_color.rgb,
					sky_clouds_1_tex.rgb * sky_clouds_1_color.rgb,
					sky_clouds_1_tex.a * sky_clouds_1_color.a
			);
			color = mix(
					base_color,
					color,
					sky_tex.a * sky_color.a * clamp(eye_dir.y * sky_distance, 0.0, 1.0)
			);
		} else {
			vec2 surface_uv = eye_dir.xz * inversesqrt(eye_dir.y) * uv_surface_scale;
			vec4 surface_tex = texture(texture_surface, surface_uv + time * uv_surface_scale * uv_surface_scroll_speed);
			color = mix(
					base_color,
					surface_tex.rgb * surface_color.rgb,
					surface_tex.a * surface_color.a * clamp(-eye_dir.y * surface_distance, 0.0, 1.0)
			);
		}

	return color;
}

void sky() {
	if (AT_CUBEMAP_PASS) {
		// don't animate the cubemap (otherwise it'll get updated every frame)
		COLOR = get_sky_color(EYEDIR, 0.0);
	} else {
		// do animate the actual background
		COLOR = get_sky_color(EYEDIR, TIME);
	}
}
