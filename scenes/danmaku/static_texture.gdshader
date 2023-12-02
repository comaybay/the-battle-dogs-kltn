shader_type canvas_item;
render_mode blend_mix;

uniform float default_orientation : hint_range(-3.14159265, 3.14159265) = 0;
uniform int target_frame : hint_range(0, 128) = 0;
uniform int texture_h_frames : hint_range(1, 128) = 1;
uniform int texture_v_frames : hint_range(1, 128) = 1;
uniform vec4 modulate : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
	float h_frames = float(texture_h_frames);
	float v_frames = float(texture_v_frames);
	
	VERTEX.xy /= vec2(h_frames, v_frames);
	VERTEX = VERTEX * mat2(vec2(cos(default_orientation), -sin(default_orientation)),
		vec2(sin(default_orientation), cos(default_orientation)));
	float total_frames = float(h_frames * v_frames);
	float frame = clamp(float(target_frame), 0.0, total_frames - 1.0);
	
	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(frame, h_frames) / h_frames, floor(frame / h_frames) / v_frames);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	COLOR = vec4(color.rgb * modulate.rgb, color.a * modulate.a * COLOR.a);
}