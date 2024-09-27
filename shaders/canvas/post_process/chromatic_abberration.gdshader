shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 split = vec2(2.0, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(
		texture(screen_texture, SCREEN_UV - split * SCREEN_PIXEL_SIZE).r,
		texture(screen_texture, SCREEN_UV).g,
		texture(screen_texture, SCREEN_UV + split * SCREEN_PIXEL_SIZE).b,
		1.0
	);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
