shader_type canvas_item;

// TEXTURE is a black-and-white image
// all white regions are converted to `light_color`
// all black regions are converted to `dark_color`

uniform vec3 light_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 dark_color: source_color = vec3(0.0, 0.0, 0.0);

uniform float x_scale = 6.0;
uniform float y_scale = 4.0;

uniform float x_scroll_speed = 0.03;
uniform float y_scroll_speed = 0.1;

void fragment() {
	vec2 tiled_uv = UV * vec2((1.0/x_scale), (1.0/y_scale));
	tiled_uv.y += TIME * y_scroll_speed;
	tiled_uv.x += TIME * x_scroll_speed;
	vec3 tex_color = texture(TEXTURE, tiled_uv).rgb;
	if (distance(tex_color, vec3(1.0)) < 0.1) {
		COLOR = vec4(light_color, 1.0);
	} else {
		COLOR = vec4(dark_color, 1.0);
	}
}
