// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode cull_back, fog_disabled, unshaded;
uniform vec4 albedo : source_color;
//uniform bool use_vertex_color = true;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_enable;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform sampler2D screen : hint_screen_texture;

#include "res://shaders/includes/psx_inc.gdshaderinc"

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	POSITION = map_affine(snap_vertex(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
}

void fragment() {
	vec2 base_uv = SCREEN_UV - vec2(0.0, TIME);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec4 screen_tex = texture(screen, SCREEN_UV - vec2(0.0, 0.5 - albedo_tex.r) * 0.05);
	ALBEDO = screen_tex.rgb * albedo.rgb; //* albedo_tex.rgb;
	ALBEDO *= COLOR.rgb;
	//ALPHA *= albedo.a * albedo_tex.a;
}
