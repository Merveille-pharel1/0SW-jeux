shader_type canvas_item;
render_mode unshaded;

uniform vec4 background_color : source_color = vec4(0.025, 0.055, 0.085, 1.0);
uniform vec4 border_color : source_color = vec4(0.30, 0.80, 1.0, 1.0);
uniform float border_width : hint_range(0.005, 0.1) = 0.035;
uniform vec2 portrait_size = vec2(76.0, 76.0);

varying vec4 vertex_modulation;
varying vec2 circle_uv;

void vertex() {
	vertex_modulation = COLOR;
	circle_uv = VERTEX / max(portrait_size, vec2(1.0));
}

void fragment() {
	vec4 modulation = vertex_modulation;
	vec4 texel = texture(TEXTURE, UV);
	
	float radius = length(circle_uv - vec2(0.5));
	float aa = max(fwidth(radius), 0.001);

	float outer = 1.0 - smoothstep(0.5 - aa, 0.5, radius);
	float inner = 1.0 - smoothstep(0.5 - border_width - aa, 0.5 - border_width, radius);

	vec3 content = mix(background_color.rgb, texel.rgb, texel.a);
	vec3 result = mix(border_color.rgb, content, inner);

	COLOR = vec4(result, outer) * modulation;
}
