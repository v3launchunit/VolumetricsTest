// random number generation functions, shamelessly stolen from godot's built-in particle process shader

#define SEED_NUM hash(NUMBER + uint(1) + RANDOM_SEED)
#define SEED_IDX hash(INDEX + uint(1) + RANDOM_SEED)

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

float rand(inout uint seed) {
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

float rand_signed(inout uint seed) {
	return rand(seed) * 2.0 - 1.0;
}
