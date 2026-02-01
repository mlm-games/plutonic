shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.5, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float glow_width : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	float outline = texture(TEXTURE, UV, -glow_width).a;
	vec3 glow = mix(original_color.rgb, glow_color.rgb, outline * glow_strength);
	COLOR = vec4(glow, original_color.a);
}
