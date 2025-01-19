shader_type particles;

//render_mode disable_velocity;

#include "res://shaders/includes/random_inc.gdshaderinc"

#define VEL_COEFFICIENT 0.5

void start() {
	// Called when a particle is spawned.
	TRANSFORM[3].x = cos(float(INDEX) / 8.0 + PI * float(int(INDEX) % 2)) * 0.5;
	TRANSFORM[3].y = float(INDEX) / 32.0 - 1.0;
	TRANSFORM[3].z = sin(float(INDEX) / 8.0 + PI * float(int(INDEX) % 2)) * 0.5;
	uint seed = SEED_NUM;
	VELOCITY = vec3(VEL_COEFFICIENT * rand_signed(seed), VEL_COEFFICIENT * rand_signed(seed), VEL_COEFFICIENT * rand_signed(seed));
	COLOR.rgb = vec3(0.0, 3.0, 1.5);
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	float alt_delta = DELTA / LIFETIME;
	//COLOR.rgb -= vec3(alt_delta);
	COLOR.a -= alt_delta;
	VELOCITY = mix(VELOCITY, vec3(0.0), alt_delta);
	//VELOCITY = vec3(cos(float(RANDOM_SEED)), 1.0, sin(float(RANDOM_SEED)));
}
