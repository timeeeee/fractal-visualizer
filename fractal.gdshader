shader_type canvas_item;

uniform float xmin = -4;
uniform float xmax = 2;
uniform float ymin = -2;
uniform float ymax = 2;
uniform bool supersample = true;

const int MAX_ITERATIONS = 1000;

float random (vec2 st) {
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


//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}


vec3 color_at_point(vec2 point) {
	int count = iteration_count(complex(point.x, point.y));
	if (count == MAX_ITERATIONS) {
		return vec3(0.0);
	}
	
	float mix_min = log(1);
	float mix_max = log(float(MAX_ITERATIONS));
	float mix_value = (log(float(count)) - mix_min) / (mix_max - mix_min);

	return hsb2rgb(vec3(mix_value, 1.0, 1.0));
}

void fragment() {
	float x = mix(xmin, xmax, UV.x);
	float y = mix(ymin, ymax, UV.y);	
	int samples = 4;
	if (supersample) {
		vec3 color_here = vec3(0.0);
		for (int x_offset = 0; x_offset < samples; x_offset++) {
			float dx = float(x_offset) * SCREEN_PIXEL_SIZE.x * (xmax - xmin) / float(samples);
			for (int y_offset = 0; y_offset < 2; y_offset++) {
				float dy = float(y_offset) * SCREEN_PIXEL_SIZE.y * (ymax - ymin) / float(samples);
				vec2 point = vec2(x + dx, y + dy);
				color_here += color_at_point(point);
			}
		}
		
		COLOR = vec4(color_here / float(samples), 1.0);
	} else {
		COLOR = vec4(color_at_point(vec2(x, y)), 1.0);
	}
}
