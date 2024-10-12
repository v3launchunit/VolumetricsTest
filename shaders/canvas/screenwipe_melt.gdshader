shader_type canvas_item;

uniform float melt_progress: hint_range(0.0, 1.0, 0.001);
uniform sampler2D melt_noise: repeat_enable, filter_linear;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float melt_offset = texture(melt_noise, UV).r * melt_progress * 10.0;
	if (melt_offset > UV.y) {
		discard;
	} else {
		COLOR = texture(TEXTURE, UV - vec2(0.0, (melt_offset)));
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
