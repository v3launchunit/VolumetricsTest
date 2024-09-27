shader_type spatial;
render_mode /*blend_add,*/ depth_draw_never, cull_back, diffuse_lambert, specular_disabled, depth_test_disabled, unshaded, shadows_disabled;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

void fragment() {
    float depth = textureLod(depth_texture, NODE_POSITION_VIEW.xy * 0.5 + 0.5, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW.xy, depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;

//	ALBEDO = vec3(-pixel_position.z * 0.1, 0, 0);
	ALBEDO = vec3(SCREEN_UV, 0);
	if (-pixel_position.z > distance(CAMERA_POSITION_WORLD, NODE_POSITION_WORLD))
	{
		ALPHA = 0.0;
	}
	else
	{
		ALPHA = 1.0;
	}
}
