shader_type spatial;

render_mode unshaded;

uniform sampler2D fade;
uniform sampler2D clouds: filter_nearest;

uniform vec2 scroll_speed = vec2(0.01);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALPHA = texture(fade, UV).a;
	ALBEDO = texture(clouds, UV + TIME * scroll_speed).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
