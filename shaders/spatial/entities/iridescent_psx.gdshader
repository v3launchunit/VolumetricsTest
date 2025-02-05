shader_type spatial;

#include "res://shaders/includes/psx_inc.gdshaderinc"

uniform float roughness: hint_range(0.0, 1.0, 0.01);
uniform sampler2D rainbow: source_color, filter_nearest, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = map_affine(snap_vertex(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
}

void fragment() {
	// Called for every pixel the material is visible on.

	float angle = dot(NORMAL, VIEW);
	ALBEDO = texture(rainbow, vec2(angle)).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
