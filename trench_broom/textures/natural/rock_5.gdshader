shader_type spatial;

group_uniforms albedo;
uniform vec3 albedo : source_color;
uniform sampler2D texture_albedo_01 : source_color, filter_nearest, repeat_enable;
uniform sampler2D texture_albedo_02 : source_color, filter_nearest, repeat_enable;
uniform sampler2D texture_albedo_03 : source_color, filter_nearest, repeat_enable;

group_uniforms normals;
uniform sampler2D texture_normal_02 : hint_normal, filter_nearest, repeat_enable;
uniform sampler2D texture_normal_03 : hint_normal, filter_nearest, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 albedo_tex_01 = texture(texture_albedo_01, UV);
	vec4 albedo_tex_02 = texture(texture_albedo_02, UV);
	vec4 albedo_tex_03 = texture(texture_albedo_03, (UV + albedo_tex_01.rg));

	ALBEDO = albedo * albedo_tex_01.rgb * albedo_tex_02.rgb * albedo_tex_03.rgb;

	vec4 normal_tex_02 = texture(texture_normal_02, UV);
	vec4 normal_tex_03 = texture(texture_normal_03, (UV + albedo_tex_01.rg));

	NORMAL_MAP = mix(normal_tex_02.rgb, normal_tex_03.rgb, albedo_tex_02.r * albedo_tex_02.r * 0.75);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
