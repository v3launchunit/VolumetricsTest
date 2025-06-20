shader_type canvas_item;

render_mode unshaded;

uniform float _progress : hint_range(0.0, 1.0, 0.01);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR.gb = mix(COLOR.gb + clamp(mix(0.0, 1.0, _progress * 10.0), 0.0, 1.0), vec2(0.0), _progress);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
