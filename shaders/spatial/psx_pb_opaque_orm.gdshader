shader_type spatial;

render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo_col : source_color = vec4(1.0);
uniform sampler2D albedo_tex : source_color,filter_nearest,repeat_enable;
//uniform float alpha_clip_threshold : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform sampler2D normal_tex : hint_roughness_normal,filter_nearest,repeat_enable;
uniform float normal_scale : hint_range(-16,16) = 1.0;
uniform float roughness : hint_range(0,1) = 0.75;
//uniform sampler2D roughness_tex : hint_roughness_r,filter_nearest,repeat_enable;
uniform float metallic : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float specular : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform sampler2D orm_tex : hint_default_white,filter_nearest,repeat_enable;
//uniform vec4 metallic_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset = vec3(0.0);
uniform vec3 uv2_scale = vec3(1.0);
uniform vec3 uv2_offset = vec3(0.0);
uniform bool is_terrain_mat = false;

#include "res://shaders/includes/psx_inc.gdshaderinc"

void vertex() {
	UV *= uv1_scale.xy + uv1_offset.xy;
	if (is_terrain_mat) {
		//UV *= 0.0625;
		POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	} else {
		POSITION = map_affine(snap_vertex(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
	}
}

void fragment() {
	vec4 albedo = COLOR * texture(albedo_tex, UV) * albedo_col;
	//if (albedo.a < alpha_clip_threshold) {
		//discard;
	//}
	ALBEDO = albedo.rgb;
	NORMAL_MAP = texture(normal_tex, UV).rgb * normal_scale;
	vec4 orm = texture(orm_tex, UV);
	METALLIC = metallic * orm.b;
	ROUGHNESS = roughness * orm.g;
	SPECULAR = specular;
}
