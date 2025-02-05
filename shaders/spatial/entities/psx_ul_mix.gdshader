// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,cull_back,unshaded;
uniform vec4 albedo : source_color;
//uniform bool use_vertex_color = true;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_enable;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

#include "res://shaders/includes/psx_inc.gdshaderinc"

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	POSITION = map_affine(snap_vertex(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}
