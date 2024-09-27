shader_type sky;

uniform vec3 sky_cubemap_color : source_color = vec3(0.25);
uniform sampler2D sky_tex : filter_nearest, repeat_enable, hint_default_transparent;
uniform sampler2D cloud_tex_a : filter_nearest, repeat_enable, hint_default_transparent;
uniform sampler2D horizon_tex : filter_nearest, repeat_enable, hint_default_transparent;
uniform float scroll_speed : hint_range(0.0, 0.5, 0.0001);

void sky() {
	if (AT_CUBEMAP_PASS) {
		// Sets the radiance cubemap to a nice shade of blue instead of doing
		// expensive sky calculations
		COLOR = sky_cubemap_color;
	} else {
		// Do expensive sky calculations for background sky only
		vec4 cloud_col_a = texture(cloud_tex_a, SKY_COORDS + TIME * scroll_speed);
		vec4 cloud_col_b = texture(cloud_tex_a, SKY_COORDS + sin(TIME) * scroll_speed);
		vec3 sky_col = mix(
				sky_cubemap_color,
				(cloud_col_a.rgb + cloud_col_b.rgb) * 0.5,
				cloud_col_a.a
		);
		vec4 horizon_col = texture(horizon_tex, SKY_COORDS);
		COLOR = mix(sky_col.rgb, horizon_col.rgb, horizon_col.a);
	}
}
