shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur: hint_range(0.0,3.0) = 1.3;

void fragment(){
	vec4 input_color = texture(screen_texture, UV, blur);
	COLOR = vec4(input_color.r,input_color.g,input_color.b,input_color.a);
}