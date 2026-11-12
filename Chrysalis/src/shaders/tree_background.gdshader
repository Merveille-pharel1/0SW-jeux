shader_type canvas_item;

uniform vec4 dye_color: source_color = vec4(1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, dye_color.rgb, 0.3);
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
