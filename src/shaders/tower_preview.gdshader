shader_type canvas_item;

uniform vec4 sprite_tint: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 outline_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width: hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	bool is_outline = false;
	
	if (tex_color.a < 1.0) {
		vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;
		float alpha = 0.0;
		
		alpha += texture(TEXTURE, UV + vec2(pixel_size.x, 0)).a;
		alpha += texture(TEXTURE, UV + vec2(-pixel_size.x, 0)).a;
		alpha += texture(TEXTURE, UV + vec2(0, pixel_size.y)).a;
		alpha += texture(TEXTURE, UV + vec2(0, -pixel_size.y)).a;
		
		if (alpha > 0.0) {
			is_outline = true;
		}
	}
	
	if (is_outline) {
		COLOR = outline_color;
	} else {
		COLOR = tex_color * sprite_tint;
	}
}