shader_type canvas_item;
render_mode unshaded;

uniform bool Smooth = true;
uniform vec2 frame_size = vec2(0, 0);
uniform vec2 frame_coords = vec2(0, 0);
uniform float width : hint_range(0.0, 64) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int pixel_size : hint_range(1, 10) = 4;
uniform float width_speed :hint_range(0.1, 10) = 1;

void fragment()
{
    float _width = width + ((sin(TIME*width_speed) + 1.0)) * 10.0;
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 unit = (1.0/float(pixel_size) ) / tex_size;
    vec4 pixel_color = texture(TEXTURE, UV);
	
	float x_min = (frame_size.x * frame_coords.x) / tex_size.x;
	float x_max = (frame_size.x * (frame_coords.x + 1.0)) / tex_size.x;
	float y_min = (frame_size.y * frame_coords.y) / tex_size.y;
	float y_max = (frame_size.y * (frame_coords.y + 1.0)) / tex_size.y;
	
	vec2 min_vec = vec2(x_min, y_min);
	vec2 max_vec = vec2(x_max, y_max);
	
    if (!(UV.x < x_min || UV.x > x_max || UV.y < y_min || UV.y > y_max) && pixel_color.a <= 0.45) {
        pixel_color = outline_color;
        pixel_color.a = 0.0;
        for (float x = -ceil(_width); x <= ceil(_width); x++) {
            for (float y = -ceil(_width); y <= ceil(_width); y++) {
				vec2 clamp_uv = clamp(UV + vec2(x*unit.x, y*unit.y), min_vec, max_vec);
                if (texture(TEXTURE, clamp_uv).a == 0.0 || (x==0.0 && y==0.0)) {
                    continue;
                }
                if (Smooth) {
                    pixel_color.a += outline_color.a / (pow(x,2)+pow(y,2)) * (1.0-pow(2.0, -_width));
                    if (pixel_color.a > 1.0) {
                        pixel_color.a = 1.0;
                    }
                } else {
                    pixel_color.a = outline_color.a;
                }
            }
        }
    }
    COLOR = pixel_color;
}