shader_type spatial;

render_mode cull_disabled;

uniform vec3 Color : source_color;
uniform sampler3D noise;

void vertex() {
	VERTEX += NORMAL * texture(noise, VERTEX / 10.0 + vec3(TIME)).x * 1.0;
}

void fragment() {
	ALBEDO = Color;
	ALPHA = texture(noise, VERTEX / 10.0 + vec3(TIME)).x; 
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
