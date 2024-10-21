shader_type canvas_item;

uniform sampler2D mask_texture : hint_default_white;

void fragment() {
	vec4 mask = texture(mask_texture, UV);
	if (mask.r < 0.5) {
		discard;
	}
	COLOR = texture(TEXTURE, UV);
}
