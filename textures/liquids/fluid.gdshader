// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_enable;
uniform sampler2D texture_emission_mask : source_color,filter_nearest_mipmap,repeat_enable;
uniform sampler2D texture_emission : source_color,filter_nearest_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_normal : hint_roughness_normal,filter_nearest_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float scroll_speed : hint_range(0.0, 1.0, 0.001);

uniform bool flowing;
uniform float flow_speed : hint_range(-1.0, 1.0, 0.001);

uniform sampler2D texture_displacement : hint_default_white,filter_nearest_mipmap,repeat_enable;
uniform float intensity : hint_range(0.0, 1.0, 0.01);

//#include "includes/psx_inc.gdshaderinc"

void vertex() {
	UV = UV + uv1_offset.xy;
	//POSITION = map_affine(snap_vertex(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
}

void fragment() {
	vec2 base_uv = UV;
	vec2 flow_uv = flowing ? vec2(
			base_uv.x,
			base_uv.y + TIME * flow_speed
	) : (base_uv + vec2(TIME, sin(TIME)) * flow_speed);
	vec2 disp_uv = base_uv + ((texture(
			texture_displacement,
			flow_uv
	).rg - 0.5) * intensity);

	vec2 uv_a = vec2(
			base_uv.x + TIME * (scroll_speed - 0.05),
			base_uv.y + TIME * scroll_speed
	);
	vec2 uv_b = vec2(
			base_uv.x + TIME * (scroll_speed + 0.1),
			base_uv.y - TIME * scroll_speed + 0.1
	);
	vec2 uv_c = vec2(
			base_uv.x - TIME * (scroll_speed + 0.05),
			base_uv.y + TIME * scroll_speed + 0.2
	);
	vec2 uv_d = vec2(
			base_uv.x - TIME * (scroll_speed - 0.1),
			base_uv.y - TIME * scroll_speed + 0.3
	);

	vec4 albedo_tex = texture(texture_albedo, flow_uv);
	vec4 albedo_tex_a = texture(texture_emission, uv_a + disp_uv);
	vec4 albedo_tex_b = texture(texture_emission, uv_b + disp_uv);
	vec4 albedo_tex_c = texture(texture_emission, uv_c + disp_uv);
	vec4 albedo_tex_d = texture(texture_emission, uv_d + disp_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	EMISSION = texture(texture_emission_mask, flow_uv).rgb * (
			albedo_tex_a.rgb
			 + albedo_tex_b.rgb
			 + albedo_tex_c.rgb
			 + albedo_tex_c.rgb
	);
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	//vec3 normal_a = texture(texture_normal,  vec2(
			//base_uv.x + TIME * scroll_speed,
			//base_uv.y + TIME * scroll_speed
	//)).rgb;
	//vec3 normal_b = texture(texture_normal,  vec2(
			//base_uv.x + TIME * scroll_speed,
			//base_uv.y + TIME * scroll_speed
	//)).rgb;
	//vec3 normal_c = texture(texture_normal,  vec2(
			//base_uv.x + TIME * scroll_speed,
			//base_uv.y + TIME * scroll_speed
	//)).rgb;
	//vec3 normal_d = texture(texture_normal,  vec2(
			//base_uv.x + TIME * scroll_speed,
			//base_uv.y + TIME * scroll_speed
	//)).rgb;
	//NORMAL_MAP = (
			//normal_a
			 //+ normal_b
			 //+ normal_c
			 //+ normal_d
	//) * 0.25;
	NORMAL_MAP = texture(texture_normal, flow_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}
