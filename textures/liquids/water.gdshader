shader_type spatial;

render_mode cull_disabled, unshaded;

//uniform int wave_count: hint_range(1, 16, 1) = 4;
//uniform float base_wave_scale: hint_range(0.0, 16.0, 0.1) = 8.0;
//uniform float base_wave_height: hint_range(0.0, 16.0, 0.1) = 1.0;
//uniform float fbm_scale_factor: hint_range(0.0, 1.0, 0.01) = 0.9;
//uniform sampler2D wave_tex: hint_default_white;
uniform float wave_speed: hint_range(0.0, 1.0, 0.01);
uniform float wave_scale: hint_range(0.0, 1.0, 0.01);
uniform vec2 uv_scale = vec2(0.125);
uniform vec3 tint: source_color = vec3(1.0);
uniform sampler2D noise_tex: hint_default_white;
uniform sampler2D screen_tex: hint_screen_texture, filter_nearest, repeat_disable;

//#include "res://shaders/includes/psx_inc.gdshaderinc"

void vertex() {
	UV *= uv_scale;
	//VERTEX.y -= texture(
			//noise_tex,
			//UV + TIME * wave_speed
	//).r;
}

void fragment() {
	ALBEDO = texture(
			screen_tex,
			SCREEN_UV + texture(
					noise_tex,
					UV + TIME * wave_speed
			).rg * wave_scale
	).rgb * tint;

	//ALBEDO = vec3(randf(FRAGCOORD.x));
	//vec3 normal = vec3(0.5, 0.5, 1.0);
	//for (int i = 0; i < wave_count; i++) {
		//normal += (
				//cos(
						//(UV.x * UV.y)
						//* ((2.0 - fbm_scale_factor) * float(i))
						/// (base_wave_scale)
				//)
				//* base_wave_height
				//* fbm_scale_factor
				//* float(i)
		//);
	//}
	//ALBEDO = normal;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
