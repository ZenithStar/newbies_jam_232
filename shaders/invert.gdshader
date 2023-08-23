shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0,0.0,0.0,1.0);

void fragment() {
	vec4 color = base_color;
	color.a = 1.0-texture(TEXTURE, UV).a;
	COLOR = color;
}
