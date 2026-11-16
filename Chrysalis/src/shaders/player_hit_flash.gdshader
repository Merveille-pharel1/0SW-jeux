shader_type canvas_item;

uniform vec4 hit_color : source_color = vec4(1.0, 0.88, 0.88, 1.0);
uniform float hit_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, hit_color.rgb, hit_strength);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
