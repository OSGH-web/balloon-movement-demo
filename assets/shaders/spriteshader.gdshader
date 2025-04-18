shader_type canvas_item;


// TEXTURE is a black-and-white image
// all white regions are converted to `light_color`
// all black regions are converted to `dark_color`

uniform vec3 light_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 dark_color: source_color = vec3(0.0, 0.0, 0.0);

uniform float x_scale = 6.0;
uniform float y_scale = 4.0;

void fragment() {
	vec2 tiled_uv = UV * vec2((1.0/x_scale), (1.0/y_scale));
	vec3 tex_color = texture(TEXTURE, tiled_uv).rgb;
	if (distance(tex_color, vec3(1.0)) < 0.1) {
		COLOR = vec4(light_color, 1.0);
	} else {
		COLOR = vec4(dark_color, 1.0);
	}
}
