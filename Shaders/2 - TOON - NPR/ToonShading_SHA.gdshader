shader_type spatial;
render_mode diffuse_lambert, ambient_light_disabled;

group_uniforms Properties;
		// Base Color
		uniform vec4 baseColor : source_color = vec4 (1.0);
group_uniforms Properties.UVTextures;
		// Sampler Texture
		uniform sampler2D albedoText: source_color, hint_default_white;
		uniform bool useTexture = true;
group_uniforms Properties.Diffuse;
		uniform float shadeOpacity : hint_range (0.0, 1.0) = 0.5; 
group_uniforms Properties.Specular;
		// Specular
		uniform bool addSpecular = true;
		// Specular >> Bright Size >> X^2
		uniform float glossSharp : hint_range (1.0, 256.0) = 64.0; 
group_uniforms Properties.RimLight;
		// Fresnel
		uniform bool addFresnel = true;
		uniform float rimEdge : hint_range (0.01, 0.9) = 0.5; 
		uniform vec4 rimLightColor : source_color = vec4 (1.0); 

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec4 colorAlbedo;
	if ( !useTexture ) 
		colorAlbedo = baseColor;
	else 
		colorAlbedo = texture(albedoText, UV ) * baseColor;

	ALBEDO  =  colorAlbedo.rgb;
}

void light() {	
//	// Called for every pixel for every light affecting the material.
	// BASIC VARIABLES
	vec3 LDIR = normalize(LIGHT);
	vec3 LCOL = LIGHT_COLOR;
	vec3 N = normalize(NORMAL);				//	Normal:	No normalised
	vec3 V = normalize(VIEW);					// 	View:	Already normalised
	
	// COMPONENTS DIFFUSE | AMBIENT
	float kD = 		0.30;
	float kA = 		0.01;
	float kS = 		1.0;
	
	// DIFFUSE | LAMBERT
	//vec3 LSPEC = 		normalize(vec3(.66, .66,.66));
	float dotNL = 	max(dot(N, normalize(LDIR)),0.0);
	// TOON
	float maskDiff = smoothstep(0.0, 0.01, dotNL); // <-- TOON
	// mix (a, b, mask) , a = 0.0 >> 1.0, b = colorLight
	vec3 mixDiff = mix(vec3( shadeOpacity ), LCOL, vec3(maskDiff));
	vec3 diffuse = 	(kD * LCOL * mixDiff) * ALBEDO * ATTENUATION;
	
	// SPECULAR
	vec3 H = 			normalize(LDIR + V);
	float specular =	pow(max( dot(N, H), 0.0), glossSharp ) ;
	float maskSpec = 	smoothstep(0.01, 0.5, specular);
	
	// LIGHTS + SPECULAR
	float toggleSpec = 	float (addSpecular) ;
	vec3 totalSpec = kS *  LCOL * ALBEDO * maskSpec * toggleSpec;
	vec3 L = diffuse;
	
	float dotVN = max(dot(V, N), 0.0);
	float invertVN = 1.0 - dotVN;
	float fresnel = invertVN * float(addFresnel) * ATTENUATION ;
	float maskFres = smoothstep(rimEdge, 0.8, fresnel);
	
	DIFFUSE_LIGHT = L + totalSpec + ( vec3(maskFres) * rimLightColor.rgb);
	
}
