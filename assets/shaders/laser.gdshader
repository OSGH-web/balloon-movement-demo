shader_type canvas_item;

uniform vec3 light_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 dark_color: source_color = vec3(0.0, 0.0, 0.0);

uniform float animation_rate = 1.9;
uniform float pixelate_amount = 256.;
uniform float rotation = 0.;
uniform float scale = 6.;
uniform float scroll_speed = 8.;

uniform float dist_factor = 1.0;
uniform float radius_median = 1.3;
uniform float radius_ampl = 0.1;
uniform float sharpness = .85;
uniform float n_target_circles = 5.0;

vec2 pixelate(vec2 uv, float amount) {
	return floor(uv * amount) / amount;
}

vec2 scaleFullscreen(vec2 uv) {
     return (uv - 0.5) * vec2(16./25., 9.0/25.); // aspect ratio optional
}

vec2 rotate(vec2 uv, float ang) {
	float s = sin(ang * 2. * PI / 360.);
	float c = cos(ang * 2. * PI / 360.);
	return uv * mat2(vec2(c, -s), vec2(s, c));
}

float quantizeTime(float time, float resolution) {
	return floor(time * resolution) / resolution;
}

void fragment() {
	float time = quantizeTime(TIME, 12.0);
	float t = time * animation_rate;
	
    vec2 uv = pixelate(UV, pixelate_amount);
	uv = scaleFullscreen(uv);
	uv = rotate(uv, rotation);
	uv.x += time * scroll_speed / 10.;
	uv *= scale;
	// gv == grid coordinate, range b/w -.5 and .5
	vec2 gv = fract(uv) - 0.5;
	// unique identifier of the current grid square
	vec2 id = floor(uv);

	//	accumulated brightness for all circles
	float brightness = 0.0;
	for (float y=-1.; y<=1.; y++){
		for (float x=-1.; x<=1.; x++){
			vec2 offset = vec2(x, y);

			float d = length(gv - offset);

			float dist = length(id  +  offset) * dist_factor;
			float r = mix(radius_median - radius_ampl, radius_median + radius_ampl,  0.5 * sin((t + dist)) + 0.5);
			brightness += smoothstep(r, r*sharpness, d);
		}
	}
	brightness = mod(brightness, n_target_circles);

	if (length(COLOR.rgb - vec3(0.0, 0.6, 0.859)) < 0.1 || length(COLOR.rgb - vec3(0.173, 0.91, 0.961)) < 0.1 || length(COLOR.rgb - vec3(1.0, 1.0, 1.0)) < 0.1) {
		if (abs(n_target_circles - brightness - 1.0) < 0.25) {
			COLOR =  vec4(light_color, COLOR.a);
		}
		else if (abs(n_target_circles - brightness) < 0.5 ) {
			COLOR = vec4(dark_color, COLOR.a);
		}
	}
}
