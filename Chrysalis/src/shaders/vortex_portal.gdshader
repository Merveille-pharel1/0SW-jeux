shader_type canvas_item;

uniform vec2 centre = vec2(0.52, 0.62);

uniform vec2 rayon = vec2(0.16, 0.19);

uniform float vitesse : hint_range(-8.0, 8.0, 0.05) = 0.8;

varying vec4 teinte_sprite;

void vertex() {
    teinte_sprite = COLOR;
}

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    vec2 position = (UV - centre) / rayon;
    float distance_centre = length(position);

    float angle = TIME * vitesse;
    float c = cos(angle);
    float s = sin(angle);
    vec2 rotation = vec2(
        position.x * c - position.y * s,
        position.x * s + position.y * c
    );

    vec4 vortex = texture(TEXTURE, centre + rotation * rayon);

    float masque = 1.0 - smoothstep(0.65, 1.0, distance_centre);
    COLOR = mix(original, vortex, masque) * teinte_sprite;
}