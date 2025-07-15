// NOTE: Shader automatically converted from Godot Engine 4.4.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms albedo;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

group_uniforms orm;
uniform float roughness : hint_range(0.0, 1.0) = 0.75;
uniform sampler2D texture_metallic : hint_default_white, filter_nearest, repeat_enable;
uniform vec4 metallic_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform sampler2D texture_roughness : hint_roughness_r, filter_nearest, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

group_uniforms normals;
uniform sampler2D texture_normal : hint_roughness_normal, filter_nearest, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

group_uniforms clearcoat;
uniform float clearcoat : hint_range(0,1);
uniform float clearcoat_roughness : hint_range(0,1);
uniform sampler2D texture_clearcoat : hint_default_white, filter_nearest, repeat_enable;

group_uniforms detail;
uniform sampler2D texture_detail_mask : hint_default_black, filter_nearest, repeat_enable;
uniform sampler2D texture_detail_normal : hint_roughness_normal, filter_nearest, repeat_enable;
uniform float detail_normal_scale = 1.0;

group_uniforms uv;
uniform sampler2D texture_uv_warp : hint_default_white, filter_nearest, repeat_enable;
uniform vec2 uv_warp_dir = vec2(0.0, 1.0);

uniform vec2 uv1_base_scale = vec2(1.0);
uniform vec2 uv1_base_offset;
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset;
uniform vec3 uv2_scale = vec3(1.0);
uniform vec3 uv2_offset;
uniform vec3 uv3_scale = vec3(1.0);
uniform vec3 uv3_offset;

void vertex() {
	UV = fma(UV, uv1_base_scale, uv1_base_offset);
}

void fragment() {
	float offset = texture(texture_uv_warp, UV).r;
	vec2 uv3 = UV * uv3_scale.xy;
	vec2 base_uv = vec2(0.5, 0.25) * UV * uv1_scale.xy + uv1_offset.xy + (vec2(offset * 0.015625) * uv_warp_dir);

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	float detail = texture(texture_detail_mask, uv3).r;
	NORMAL_MAP = mix(texture(texture_normal, base_uv).rgb, texture(texture_detail_normal, uv3).rgb, detail);
	NORMAL_MAP_DEPTH = mix(normal_scale, detail_normal_scale, detail);

	vec2 clearcoat_tex = texture(texture_clearcoat, base_uv).xy;
	CLEARCOAT = clearcoat * clearcoat_tex.x;
	CLEARCOAT_ROUGHNESS = clearcoat_roughness * clearcoat_tex.y;
}
