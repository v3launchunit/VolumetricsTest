shader_type spatial;

uniform float normal_scale = 1.0;
uniform float roughness = 0.75;
uniform float metallic = 0.0;

uniform vec2 uv_base_scale = vec2(1.0);
uniform vec2 uv_tile_scale = vec2(1.0);
uniform vec2 uv_detail_scale = vec2(0.0625);
uniform vec2 uv_flux_scale = vec2(0.0625);

uniform sampler2D tile_albedo: source_color, filter_nearest, repeat_enable;
uniform sampler2D tile_normals: hint_normal, filter_nearest, repeat_enable;
uniform sampler2D detail_mask: hint_default_black, filter_nearest, repeat_enable;
uniform sampler2D detail_albedo: source_color, filter_nearest, repeat_enable;
uniform sampler2D detail_normals: hint_normal, filter_nearest, repeat_enable;
uniform sampler2D flux_map: hint_default_black, filter_nearest, repeat_enable;
uniform sampler2D flux_noise: hint_default_white, filter_nearest, repeat_enable;
uniform sampler2D flux_palette: source_color, filter_nearest, repeat_enable;

void vertex() {
	UV *= uv_base_scale;
}

void fragment() {
	vec2 tile_uv = UV * uv_tile_scale;
	vec4 color_a = texture(tile_albedo, tile_uv);
	vec4 color_n = texture(tile_normals, tile_uv);

	vec2 detail_uv = UV * uv_detail_scale;
	vec2 detail = texture(detail_mask, tile_uv).xy;
	color_a *= mix(vec4(1.0), texture(detail_albedo, detail_uv), detail.x);
	color_n = mix(color_n, texture(detail_normals, detail_uv), detail.y);

	vec3 flux_pos = texture(flux_map, tile_uv * uv_flux_scale).xyz;
	if (abs(flux_pos.z - 1.0) < 0.01) {
		vec4 color_flux = texture(flux_palette, texture(flux_noise, flux_pos.xy).xy);
		color_a *= color_flux;
	}

	ALBEDO = color_a.rgb;
	NORMAL_MAP = color_n.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
