shader_type spatial;

render_mode unshaded, blend_add, cull_disabled;

uniform float scale = 1.0;
uniform float dance_rate: hint_range(0.01, 1.0, 0.01) = 1.0;
uniform sampler2D dance_tex: hint_default_white;
uniform vec3 col: source_color;
uniform sampler2D tex: hint_default_white;

#include "res://shaders/includes/psx_inc.gdshaderinc"

void vertex() {
	//VERTEX.xz += vec2( // cos(TIME * cos(VERTEX.y * E) + tan(VERTEX.y * E)) +
			//sin(float(floatBitsToInt(VERTEX.y * floor(TIME*dance_rate) * PI) << 5)) * scale,
			//cos(float(floatBitsToInt(VERTEX.y * floor(TIME*dance_rate) * E) << 5)) * scale
	//);
	VERTEX.xz += abs(VERTEX.y) > 0.4999 ? vec2(0.0) : (vec2(
			texture(dance_tex, vec2(
					sin(
							(TIME * dance_rate)
							+ sin(float(floatBitsToInt(VERTEX.y * VERTEX.y * PI) ^ floatBitsToInt(TAU)))
					), 0.0)
			).r,
			texture(dance_tex, vec2(0.0,
					cos(
							(TIME * dance_rate)
							+ sin(float(floatBitsToInt(VERTEX.y * VERTEX.y * E) >> 4))
					))
			).r
	) * scale - scale * .5);
	POSITION = map_affine(snap_vertex(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb * col;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
