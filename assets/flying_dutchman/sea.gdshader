shader_type spatial;

//render_mode unshaded;

uniform sampler2D noise;
uniform vec3 Color : source_color;
uniform vec3 Color2 : source_color;

float get_value(vec2 uv)
{
	vec2 time = vec2(0.0, TIME / 50.0);
	float n1 = texture(noise, uv + time * 2.0).x;
	float n2 = texture(noise, uv + time.yy).x;
	float n3 = texture(noise, uv.yx + time).x / 2.0;
	float value = (n1 + n2 + n3) * 0.3333;
	return value;
}

void vertex() {
	float value = get_value(UV);
	VERTEX += vec3(0, value * value * value * 30.0, 0);
}

void fragment() {
	vec2 time = vec2(0.0, TIME / 50.0);
	float value = get_value(UV);
	EMISSION = mix(Color2, Color, value * value * value * value) * 1.0;
	ALBEDO = vec3(0);

	//EMISSION = mix(Color2, Color, texture(noise, UV + time).x) * 1.0;
	//ROUGHNESS = 0.0;
	//METALLIC = 0.5;
}

void light() {
	DIFFUSE_LIGHT = vec3(0);
	SPECULAR_LIGHT = vec3(0);
}
