shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform sampler2D tex : source_color,filter_nearest_mipmap,repeat_enable;
uniform sampler2D tex_2 : source_color,filter_linear,repeat_disable;
uniform sampler2D noise : source_color,filter_nearest_mipmap,repeat_enable;
uniform float intensity : hint_range(0.0, 1.0, 0.01);
uniform float scroll_speed : hint_range(0.0, 4.0, 0.01);
instance uniform vec2 uv_scale = vec2(1.0, 1.0);

void vertex() {
	//UV += (vec4(VERTEX, 0) * MODEL_MATRIX).yz;
	UV = UV * uv_scale;
	//UV = vec2(
			//dot(MODEL_MATRIX * vec4(VERTEX, 1.0), vec4(BINORMAL, 0.0)) - 0.5,
			//dot(MODEL_MATRIX * vec4(VERTEX, 1.0), vec4(NORMAL, 0.0)) - 0.5
	//);
}

void fragment() {
	vec2 base_uv = UV;
	vec2 uv = base_uv + (texture(noise, base_uv + TIME * scroll_speed).rg - 0.5) * intensity;
	ALBEDO = texture(tex, uv).rgb * texture(tex_2, uv).rgb;
	ALPHA = texture(tex, uv).a * texture(tex_2, uv).a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
