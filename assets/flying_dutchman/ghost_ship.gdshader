shader_type spatial;

render_mode cull_disabled;

uniform vec3 Color : source_color;
uniform sampler3D noise;
uniform vec3 albedo: source_color;
uniform float progress: hint_range(0.0, 1.0, 0.01);

void vertex() {
	//VERTEX += NORMAL * texture(noise, VERTEX / 10.0 + vec3(TIME)).x * 1.0;
}

void fragment() {
	//DEPTH = 0.0;
	ALBEDO = mix(Color, albedo, progress);
	ALPHA = mix(texture(noise, VERTEX / 10.0 + vec3(TIME)).x * 0.5, 1.0, progress);
	EMISSION = mix(Color * 2.0, vec3(0), progress);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
