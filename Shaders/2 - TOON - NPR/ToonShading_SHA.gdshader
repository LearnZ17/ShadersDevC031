shader_type spatial;
render_mode unshaded, cull_disabled; // Flat - Don't calculate any type of light

group_uniforms UVTextures;
		uniform sampler2D albedoTexture: source_color, hint_default_white;
		
group_uniforms Properties;
		// Base Color
		uniform vec3 ambientColor : source_color = vec3 (1.0); 
		
		// Specular
		uniform bool addSpecular = true;
		
		// Fresnel
		uniform bool addFresnel = true;
		
		// Angle Light
		uniform float angleLight : hint_range(-1.0, 1.0, 0.1);		

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	ALBEDO =  texture( albedoTexture, UV ).rgb;
}

void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
}
