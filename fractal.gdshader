shader_type canvas_item;

uniform float xmin = -4;
uniform float xmax = 2;
uniform float ymin = -2;
uniform float ymax = 2;
uniform bool dither = true;

const int MAX_ITERATIONS = 1000;float random (vec2 st) {
    return fract(sin(dot(
		st.xy,
		vec2(12.9898,78.233))) * 43758.5453123);
}

struct complex {
	float real;
	float imag;
};

complex cadd(complex a, complex b) {
	return complex(a.real + b.real, a.imag + b.imag);
}

complex cmul(complex a, complex b) {
	return complex(
		a.real * b.real - a.imag * b.imag,
		a.real * b.imag + a.imag * b.real
	);
}

complex cpow(complex base, float power) {
	// for now just square lol
	return cmul(base, base);
	/*
	complex result = complex(1.0, 0.0);
	for (int i = 0; i < power; i++) {
		result = cmul(result, base);
	}
	return result;
	*/
}

float cabs_squared(complex c) {
	return pow(c.real, 2.0) + pow(c.imag, 2.0);
}

/*
float magnitude_squared(vec2 c) {
	return c.x * c.x + c.y * c.y;
}
*/

/*
vec2 to_polar(vec2 c) {
	float r = sqrt(magnitude_squared(c));
	float theta = acos(c.x / r);
	return vec2(r, theta);
}
*/

// repeat z = z * z + c until beyond 2,2
int iteration_count(complex c) {
	complex z = c;
	for (int i = 0; i < MAX_ITERATIONS; i++) {
		z = cadd(cpow(z, 2), c);
		if (cabs_squared(z) > 4.0) {
			return i;
		}
	}

	return MAX_ITERATIONS;
}

vec3 color_at_point(vec2 point) {
	int count = iteration_count(complex(point.x, point.y));
	if (count == MAX_ITERATIONS) {
		return vec3(0.0);
	}
	
	float mix_min = log(1);
	float mix_max = log(float(MAX_ITERATIONS));
	float mix_value = (log(float(count)) - mix_min) / (mix_max - mix_min);

	vec3 red = vec3(1.0, 0.0, 0.0);
	vec3 blue = vec3(0.0, 0.0, 1.0);
	vec3 green = vec3(0.0, 1.0, 0.0);
	
	// blue -> red -> green -> blue -> red
	vec3 min_color;
	vec3 max_color;
	if (mix_value < .25) {
		min_color = blue;
		max_color = red;
	} else if (mix_value < .5) {
		min_color = red;
		max_color = green;
	} else if (mix_value < .75) {
		min_color = green;
		max_color = blue;
	} else {
		min_color = blue;
		max_color = red;
	}

	// return mix(red, blue, float(count) / float(MAX_ITERATIONS));
	return mix(min_color, max_color, mix_value * 4.0);
}

void fragment() {
	float x = mix(xmin, xmax, UV.x);
	float y = mix(ymin, ymax, UV.y);
	
	// sample a random point!
	if (dither) {
		float next_x = mix(xmin, xmax, UV.x + SCREEN_PIXEL_SIZE.x);
		float next_y = mix(ymin, ymax, UV.y + SCREEN_PIXEL_SIZE.y);
		x = mix(x, next_x, random(UV * TIME));
		y = mix(y, next_y, random(UV * TIME));
	}
	
	COLOR = vec4(color_at_point(vec2(x, y)), 1.0);
	
	// sample random point
	
	
	/*
	// super sample! plus or minus 1/4 of the pixel size
	vec3 color_here = vec3(0.0);
	for (int x_offset = -1; x_offset < 2; x_offset += 2) {
		float dx = float(x_offset) * SCREEN_PIXEL_SIZE.x / 4.0;
		for (int y_offset = -1; y_offset < 2; y_offset += 2) {
			float dy = float(y_offset) * SCREEN_PIXEL_SIZE.y / 4.0;
			vec2 point = vec2(x + dx, y + dy);
			color_here += color_at_point(point);
		}
	}
	*/
}
