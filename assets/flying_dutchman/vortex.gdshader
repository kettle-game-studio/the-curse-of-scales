shader_type spatial;

render_mode unshaded;

uniform sampler2D noise;
uniform vec3 Color : source_color;
uniform vec3 Color2 : source_color;

void vertex() {
	vec2 time = vec2(0.0, TIME / 100.0);
	float n1 = texture(noise, UV).x;
	float n2 = texture(noise, UV + time).x / 2.0;
	VERTEX += (n1 + n2) * (vec3(0.0, 1.0, 0.0) + NORMAL) * 50.0;
}

void fragment() {
	vec2 time = vec2(0.0);//vec2(TIME / 10.0, 0.0);
	ALBEDO = mix(Color2, Color, texture(noise, UV + time).xyz);
}

//void light() {
	//DIFFUSE_LIGHT = ALBEDO;
	//SPECULAR_LIGHT = ALBEDO;
//}
