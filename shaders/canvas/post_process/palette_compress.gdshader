shader_type canvas_item;

render_mode unshaded;

uniform bool mode_is_palette;
uniform float color_depth : hint_range(1.0, 256.0, 1.0);
uniform sampler3D palette : filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (mode_is_palette) {
		//COLOR = pow(texture(palette, sqrt(texture(screen_texture, SCREEN_UV).rgb)), vec4(2.0));
		COLOR = (1.0 / color_depth) * round(sqrt(texture(
				screen_texture, SCREEN_UV)) * color_depth);
		COLOR = texture(palette, COLOR.rgb);
	} else {
		COLOR = (1.0 / color_depth) * round(sqrt(texture(
				screen_texture, SCREEN_UV)) * color_depth);
	}
	COLOR *= COLOR;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
