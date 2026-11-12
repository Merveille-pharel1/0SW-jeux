shader_type canvas_item;

uniform float delay : hint_range(0.5, 5.0, 0.5) = 2.4;
uniform float intensity : hint_range(0.0, 1.0, 0.05) = 0.35; 
uniform float white_percentage : hint_range(0.0, 1.0, 0.1) = 0.6;

void fragment() {
	float dominance_cyan = min(COLOR.g, COLOR.b) - COLOR.r;
	float mask = smoothstep(0.05, 0.3, dominance_cyan);
	
	float pulsation = 0.5 + 0.5 * sin(TIME * TAU / delay);
    vec3 color_min = COLOR.rgb * (1.0 - intensity);
	vec3 color_max = mix(COLOR.rgb, vec3(1.0), white_percentage);
	
	vec3 color_pulsed = mix(color_min, color_max, pulsation);
	COLOR.rgb = mix(COLOR.rgb, color_pulsed, mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
