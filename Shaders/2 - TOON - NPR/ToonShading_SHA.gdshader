shader_type spatial;
render_mode diffuse_lambert, ambient_light_disabled;

group_uniforms UVTextures;
		uniform bool useTexture = true;
		uniform sampler2D albedoText: source_color, hint_default_white;
		
group_uniforms Properties;
		// Base Color
		uniform vec3 ambientColor : source_color = vec3 (1.0); 
		// Specular
		uniform bool addSpecular = true;
		// Fresnel
		uniform bool addFresnel = true;

varying vec3 view_dir;

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec3 colorAlbedo;
	if ( !useTexture ) {
		colorAlbedo = vec3(0.0, 0.5,1.0);
	} 
	else 
	{
		colorAlbedo = texture(albedoText, UV ).rgb;
	}
	
	ALBEDO  =  colorAlbedo;
	EMISSION =  colorAlbedo * vec3 (0.05, 0.08, 0.12);
	view_dir = normalize(-VERTEX);
}

void light() {	
//	// Called for every pixel for every light affecting the material.
	// BASIC VARIABLES
	vec3 LDIR = normalize(LIGHT);
	vec3 LCOL = LIGHT_COLOR;
	vec3 N = normalize(NORMAL);				//	Normal:	No normalised
	vec3 V = normalize(VIEW);					// 	View:	Already normalised
	float GlossSharp = 64.0;		// Specular >> Bright Size >> X^2
	
	// COMPONENTS DIFFUSE | AMBIENT
	vec3  kD = 			ambientColor * 0.5;
	float kA = 			0.01;
	float kS = 			1.0;
	
	// DIFFUSE | LAMBERT
	//vec3 LSPEC = 		normalize(vec3(.66, .66,.66));
	float dotNL = 	max(dot(N, normalize(LDIR)), 0.0);
	// TOON
	float maskDiff = smoothstep(0.01, 0.1, dotNL); // <-- TOON
	vec3 mixDiff = mix(vec3(0.01), LCOL, vec3(maskDiff));
	vec3 diffuse = 	(kD * LCOL * mixDiff) * ALBEDO * ATTENUATION;
	
	// SPECULAR
	vec3 H = 			normalize(LDIR + V);
	float specular =	pow(max( dot(N, H), 0.0), GlossSharp ) ;
	float maskSpec = 	smoothstep(0.01, 0.5, specular);
	
	// LIGHTS + SPECULAR
	float toggleSpec = 	float (addSpecular) ;
	vec3 totalSpec = (kS *  LCOL * maskSpec * toggleSpec);
	vec3 L = diffuse + totalSpec;
	
	DIFFUSE_LIGHT += L * ATTENUATION;
}
