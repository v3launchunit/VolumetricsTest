// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's ParticleProcessMaterial.

shader_type particles;
render_mode disable_velocity;

uniform vec3 direction;
uniform float spread;
uniform float flatness;
uniform float inherit_emitter_velocity_ratio = 0.0;
uniform float initial_linear_velocity_min;
uniform float initial_linear_velocity_max;
uniform float directional_velocity_min;
uniform float directional_velocity_max;
uniform float angular_velocity_min;
uniform float angular_velocity_max;
uniform float orbit_velocity_min;
uniform float orbit_velocity_max;
uniform float radial_velocity_min;
uniform float radial_velocity_max;
uniform float linear_accel_min;
uniform float linear_accel_max;
uniform float radial_accel_min;
uniform float radial_accel_max;
uniform float tangent_accel_min;
uniform float tangent_accel_max;
uniform float damping_min;
uniform float damping_max;
uniform float initial_angle_min;
uniform float initial_angle_max;
uniform float scale_min;
uniform float scale_max;
uniform float hue_variation_min;
uniform float hue_variation_max;
uniform float anim_speed_min;
uniform float anim_speed_max;
uniform float anim_offset_min;
uniform float anim_offset_max;
uniform float lifetime_randomness;
uniform vec3 emission_shape_offset = vec3(0.0);
uniform vec3 emission_shape_scale = vec3(1.0);
uniform vec3 velocity_pivot = vec3(0.0);
uniform vec3 emission_box_extents;
uniform vec4 color_value : source_color;
uniform vec3 gravity;
uniform sampler2D color_ramp : repeat_disable;
uniform float collision_friction;
uniform float collision_bounce;

vec4 rotate_hue(vec4 current_color, float hue_rot_angle) {
	float hue_rot_c = cos(hue_rot_angle);
	float hue_rot_s = sin(hue_rot_angle);
	mat4 hue_rot_mat =
			mat4(vec4(0.299, 0.587, 0.114, 0.0),
					vec4(0.299, 0.587, 0.114, 0.0),
					vec4(0.299, 0.587, 0.114, 0.0),
					vec4(0.000, 0.000, 0.000, 1.0)) +
			mat4(vec4(0.701, -0.587, -0.114, 0.0),
					vec4(-0.299, 0.413, -0.114, 0.0),
					vec4(-0.300, -0.588, 0.886, 0.0),
					vec4(0.000, 0.000, 0.000, 0.0)) *
					hue_rot_c +
			mat4(vec4(0.168, 0.330, -0.497, 0.0),
					vec4(-0.328, 0.035, 0.292, 0.0),
					vec4(1.250, -1.050, -0.203, 0.0),
					vec4(0.000, 0.000, 0.000, 0.0)) *
					hue_rot_s;
	return hue_rot_mat * current_color;
}

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0) {
		s += 2147483647;
	}
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

struct DisplayParameters {
	vec3 scale;
	float hue_rotation;
	float animation_speed;
	float animation_offset;
	float lifetime;
	vec4 color;
	float emission_texture_position;
};

struct DynamicsParameters {
	float angle;
	float angular_velocity;
	float initial_velocity_multiplier;
	float directional_velocity;
	float radial_velocity;
	float orbit_velocity;
};

struct PhysicalParameters {
	float linear_accel;
	float radial_accel;
	float tangent_accel;
	float damping;
};

void calculate_initial_physical_params(inout PhysicalParameters params, inout uint alt_seed) {
	params.linear_accel = mix(linear_accel_min, linear_accel_max, rand_from_seed(alt_seed));
	params.radial_accel = mix(radial_accel_min, radial_accel_max, rand_from_seed(alt_seed));
	params.tangent_accel = mix(tangent_accel_min, tangent_accel_max, rand_from_seed(alt_seed));
	params.damping = mix(damping_min, damping_max, rand_from_seed(alt_seed));
}

void calculate_initial_dynamics_params(inout DynamicsParameters params, inout uint alt_seed) {
	// -------------------- DO NOT REORDER OPERATIONS, IT BREAKS VISUAL COMPATIBILITY
	// -------------------- ADD NEW OPERATIONS AT THE BOTTOM
	params.angle = mix(initial_angle_min, initial_angle_max, rand_from_seed(alt_seed));
	params.angular_velocity = mix(angular_velocity_min, angular_velocity_max, rand_from_seed(alt_seed));
	params.initial_velocity_multiplier = mix(initial_linear_velocity_min, initial_linear_velocity_max, rand_from_seed(alt_seed));
	params.directional_velocity = mix(directional_velocity_min, directional_velocity_max, rand_from_seed(alt_seed));
	params.radial_velocity = mix(radial_velocity_min, radial_velocity_max, rand_from_seed(alt_seed));
	params.orbit_velocity = mix(orbit_velocity_min, orbit_velocity_max, rand_from_seed(alt_seed));
}

void calculate_initial_display_params(inout DisplayParameters params, inout uint alt_seed) {
	// -------------------- DO NOT REORDER OPERATIONS, IT BREAKS VISUAL COMPATIBILITY
	// -------------------- ADD NEW OPERATIONS AT THE BOTTOM
	float pi = 3.14159;
	params.scale = vec3(mix(scale_min, scale_max, rand_from_seed(alt_seed)));
	params.scale = sign(params.scale) * max(abs(params.scale), 0.001);
	params.hue_rotation = pi * 2.0 * mix(hue_variation_min, hue_variation_max, rand_from_seed(alt_seed));
	params.animation_speed = mix(anim_speed_min, anim_speed_max, rand_from_seed(alt_seed));
	params.animation_offset = mix(anim_offset_min, anim_offset_max, rand_from_seed(alt_seed));
	params.lifetime = (1.0 - lifetime_randomness * rand_from_seed(alt_seed));
	params.color = color_value;
}

void process_display_param(inout DisplayParameters parameters, float lifetime) {
	// Compile-time add textures.
	parameters.color *= texture(color_ramp, vec2(lifetime));
	parameters.color = rotate_hue(parameters.color, parameters.hue_rotation);
}

vec3 calculate_initial_position(inout DisplayParameters params, inout uint alt_seed) {
	float pi = 3.14159;
	vec3 pos = vec3(0.0);
	{ // Emission shape.
		pos = vec3(rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0) * emission_box_extents;
	}
	return pos * emission_shape_scale + emission_shape_offset;
}

vec3 get_random_direction_from_spread(inout uint alt_seed, float spread_angle) {
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;
	float spread_rad = spread_angle * degree_to_rad;
	float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;
	float angle2_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad * (1.0 - flatness);
	vec3 direction_xz = vec3(sin(angle1_rad), 0.0, cos(angle1_rad));
	vec3 direction_yz = vec3(0.0, sin(angle2_rad), cos(angle2_rad));
	direction_yz.z = direction_yz.z / max(0.0001, sqrt(abs(direction_yz.z))); // Better uniform distribution.
	vec3 spread_direction = vec3(direction_xz.x * direction_yz.z, direction_yz.y, direction_xz.z * direction_yz.z);
	vec3 direction_nrm = length(direction) > 0.0 ? normalize(direction) : vec3(0.0, 0.0, 1.0);
	// Rotate spread to direction.
	vec3 binormal = cross(vec3(0.0, 1.0, 0.0), direction_nrm);
	if (length(binormal) < 0.0001) {
		// Direction is parallel to Y. Choose Z as the binormal.
		binormal = vec3(0.0, 0.0, 1.0);
	}
	binormal = normalize(binormal);
	vec3 normal = cross(binormal, direction_nrm);
	spread_direction = binormal * spread_direction.x + normal * spread_direction.y + direction_nrm * spread_direction.z;
	return normalize(spread_direction);
}

vec3 process_radial_displacement(DynamicsParameters param, float lifetime, inout uint alt_seed, mat4 transform, mat4 emission_transform, float delta) {
	vec3 radial_displacement = vec3(0.0);
	if (delta < 0.001) {
		return radial_displacement;
	}
	float radial_displacement_multiplier = 1.0;
	vec3 global_pivot = (emission_transform * vec4(velocity_pivot, 1.0)).xyz;
	if (length(transform[3].xyz - global_pivot) > 0.01) {
		radial_displacement = normalize(transform[3].xyz - global_pivot) * radial_displacement_multiplier * param.radial_velocity;
	} else {
		radial_displacement = get_random_direction_from_spread(alt_seed, 360.0) * param.radial_velocity;
	}
	if (radial_displacement_multiplier * param.radial_velocity < 0.0) {
		// Prevent inwards velocity to flicker once the point is reached.
		radial_displacement = normalize(radial_displacement) * min(abs(radial_displacement_multiplier * param.radial_velocity), length(transform[3].xyz - global_pivot) / delta);
	}
	return radial_displacement;
}

void process_physical_parameters(inout PhysicalParameters params, float lifetime_percent) {
}

void start() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	DisplayParameters params;
	calculate_initial_display_params(params, alt_seed);
	// Reset alt seed?
	//alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	DynamicsParameters dynamic_params;
	calculate_initial_dynamics_params(dynamic_params, alt_seed);
	PhysicalParameters physics_params;
	calculate_initial_physical_params(physics_params, alt_seed);
	process_display_param(params, 0.0);
	if (rand_from_seed(alt_seed) > AMOUNT_RATIO) {
		ACTIVE = false;
	}

	if (RESTART_CUSTOM) {
		CUSTOM = vec4(0.0);
		CUSTOM.w = params.lifetime;
		CUSTOM.x = dynamic_params.angle;
	}
	if (RESTART_COLOR) {
		COLOR = params.color;
	}
	if (RESTART_ROT_SCALE) {
		TRANSFORM[0].xyz = vec3(1.0, 0.0, 0.0);
		TRANSFORM[1].xyz = vec3(0.0, 1.0, 0.0);
		TRANSFORM[2].xyz = vec3(0.0, 0.0, 1.0);
	}
	if (RESTART_POSITION) {
		TRANSFORM[3].xyz = calculate_initial_position(params, alt_seed);
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	}
	if (RESTART_VELOCITY) {
		VELOCITY = get_random_direction_from_spread(alt_seed, spread) * dynamic_params.initial_velocity_multiplier;
	}

	process_display_param(params, 0.0);

	VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
	VELOCITY += EMITTER_VELOCITY * inherit_emitter_velocity_ratio;

	float pitch = mix(-PI, PI, rand_from_seed(alt_seed));
	float yaw = mix(-PI, PI, rand_from_seed(alt_seed));
	float roll = mix(-PI, PI, rand_from_seed(alt_seed));

	TRANSFORM *= mat4(
		vec4(cos(pitch) * cos(yaw), cos(pitch) * sin(yaw), -sin(pitch), 0.0),
		vec4(sin(pitch) * cos(yaw) * sin(roll) - sin(yaw) * cos(roll), sin(pitch) * sin(yaw) * sin(roll) + cos(yaw) * cos(roll), cos(pitch) * sin(roll), 0.0),
		vec4(sin(pitch) * cos(yaw) * cos(roll) + sin(yaw) * sin(roll), sin(pitch) * sin(yaw) * cos(roll) - cos(yaw) * sin(roll), cos(pitch) * cos(roll), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
}

void process() {
	uint base_number = NUMBER;
	//if (repeatable) {
	//	base_number = INDEX;
	//}
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	DisplayParameters params;
	calculate_initial_display_params(params, alt_seed);
	DynamicsParameters dynamic_params;
	calculate_initial_dynamics_params(dynamic_params, alt_seed);
	PhysicalParameters physics_params;
	calculate_initial_physical_params(physics_params, alt_seed);

	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	CUSTOM.y += DELTA / LIFETIME;
	CUSTOM.y = mix(CUSTOM.y, 1.0, INTERPOLATE_TO_END);
	float lifetime_percent = CUSTOM.y / params.lifetime;
	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}

	// Calculate all velocity.
	vec3 controlled_displacement = vec3(0.0);
	controlled_displacement += process_radial_displacement(dynamic_params, lifetime_percent, alt_seed, TRANSFORM, EMISSION_TRANSFORM, DELTA);

	process_physical_parameters(physics_params, lifetime_percent);
	vec3 force;
	{
		// Copied from previous version.
		vec3 pos = TRANSFORM[3].xyz;
		force = gravity;
		// Apply linear acceleration.
		force += length(VELOCITY) > 0.0 ? normalize(VELOCITY) * physics_params.linear_accel : vec3(0.0);
		// Apply radial acceleration.
		vec3 org = EMISSION_TRANSFORM[3].xyz;
		vec3 diff = pos - org;
		force += length(diff) > 0.0 ? normalize(diff) * physics_params.radial_accel : vec3(0.0);
		// Apply tangential acceleration.
		float tangent_accel_val = physics_params.tangent_accel;
		vec3 crossDiff = cross(normalize(diff), normalize(gravity));
		force += length(crossDiff) > 0.0 ? normalize(crossDiff) * tangent_accel_val : vec3(0.0);
		force += ATTRACTOR_FORCE;
		// Apply attractor forces.
		VELOCITY += force * DELTA;
	}
	{
		// Copied from previous version.
		if (physics_params.damping > 0.0) {
			float v = length(VELOCITY);
			v -= physics_params.damping * DELTA;
			if (v < 0.0) {
				VELOCITY = vec3(0.0);
			} else {
				VELOCITY = normalize(VELOCITY) * v;
			}
		}
	}

	if (COLLIDED) {
		float collision_response = dot(COLLISION_NORMAL, VELOCITY);
		float slide_to_bounce_trigger = step(2.0 / clamp(collision_bounce + 1.0, 1.0, 2.0), abs(collision_response));
		TRANSFORM[3].xyz += COLLISION_NORMAL * COLLISION_DEPTH;
		// Remove all components of VELOCITY that are not tangential to COLLISION_NORMAL.
		VELOCITY -= COLLISION_NORMAL * collision_response;
		// Apply friction only to VELOCITY across the surface (effectively decouples friction and bounce behavior).
		VELOCITY = mix(VELOCITY, vec3(0.0), clamp(collision_friction, 0.0, 1.0));
		// Add bounce velocity to VELOCITY.
		VELOCITY -= COLLISION_NORMAL * collision_response * (collision_bounce * slide_to_bounce_trigger);
	}

	// Turbulence before limiting.
	vec3 final_velocity = controlled_displacement + VELOCITY;

	TRANSFORM[3].xyz += final_velocity * DELTA;

	process_display_param(params, lifetime_percent);

	float base_angle = dynamic_params.angle;
	base_angle += CUSTOM.y * LIFETIME * dynamic_params.angular_velocity;
	CUSTOM.x = base_angle * degree_to_rad;
	COLOR = params.color;

	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
	float scale_sign_x = params.scale.x < 0.0 ? -1.0 : 1.0;
	float scale_sign_y = params.scale.y < 0.0 ? -1.0 : 1.0;
	float scale_sign_z = params.scale.z < 0.0 ? -1.0 : 1.0;
	float scale_minimum = 0.001;
	TRANSFORM[0].xyz *= scale_sign_x * max(abs(params.scale.x), scale_minimum);
	TRANSFORM[1].xyz *= scale_sign_y * max(abs(params.scale.y), scale_minimum);
	TRANSFORM[2].xyz *= scale_sign_z * max(abs(params.scale.z), scale_minimum);

	CUSTOM.z = params.animation_offset + lifetime_percent * params.animation_speed;

	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}
}
