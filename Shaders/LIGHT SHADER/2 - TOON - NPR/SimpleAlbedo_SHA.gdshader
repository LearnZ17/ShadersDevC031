shader_type spatial;
render_mode unshaded, cull_disabled;

group_uniforms UVTextures;
		uniform sampler2D albedoTexture: source_color, hint_default_white;

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO =  texture( albedoTexture, UV ).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
