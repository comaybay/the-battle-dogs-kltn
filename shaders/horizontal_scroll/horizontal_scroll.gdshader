shader_type canvas_item;

uniform float speed_scale = 0.025;

void fragment() {
	vec2 new_uv = vec2(UV.x + TIME * speed_scale, UV.y);
    vec4 c = texture(TEXTURE, new_uv);
    COLOR = c;
}
