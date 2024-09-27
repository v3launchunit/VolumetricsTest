// psx vertex snapping and affine warping functions

global uniform ivec2 screen_size;
global uniform float vertex_snap;
global uniform bool affine_warp;

vec4 snap_vertex(vec4 base_position)
{
	if (vertex_snap < 0.0) {
		return base_position;
	}

	vec4 snapped_position = base_position;
	snapped_position.xyz = base_position.xyz / base_position.w;

	vec2 snap_resulotion = floor(vec2(screen_size) * (1.0 - vertex_snap));
	snapped_position.x = floor(snap_resulotion.x * snapped_position.x) / snap_resulotion.x;
	snapped_position.y = floor(snap_resulotion.y * snapped_position.y) / snap_resulotion.y;

	snapped_position.xyz *= base_position.w;
	return snapped_position;
}

vec4 map_affine(vec4 base_position) {
	if (affine_warp)
	{
		return base_position / abs(base_position.w);
	}
	else
	{
		return base_position;
	}
}