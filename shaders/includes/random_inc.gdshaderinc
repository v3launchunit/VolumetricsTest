
float randf(float seed) {
	return sin(float(floatBitsToInt(seed) >> 2));
}