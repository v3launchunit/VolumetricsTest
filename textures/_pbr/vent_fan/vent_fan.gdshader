shader_type spatial;

uniform sampler2D wall_albedo : source_color, filter_nearest, repeat_enable;
uniform sampler2D wall_normals : hint_normal, filter_nearest, repeat_enable;

uniform sampler2D fan_albedo : source_color, filter_nearest, repeat_enable;
uniform sampler2D fan_normals : hint_normal, filter_nearest, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 wall_a = texture(wall_albedo, UV);
	vec4 fan_a = texture(fan_albedo, UV + vec2(sin(TIME), cos(TIME)));

	ALBEDO = mix(wall_a.rgb, fan_a.rgb, fan_a.a);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
