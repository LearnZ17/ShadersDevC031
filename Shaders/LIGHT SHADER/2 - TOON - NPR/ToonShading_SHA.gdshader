shader_type spatial;

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
		colorAlbedo = pow(texture(albedoText, UV), vec4(2.2)) * baseColor;

	ALBEDO  =  colorAlbedo.rgb;
}

void light() {	
//	// Called for every pixel for every light affecting the material.
	// BASIC VARIABLES (MAIN 4 VECTORS)
	vec3 L = normalize(LIGHT);
	vec3 N = normalize(NORMAL);				//	Normal:	No normalised
	vec3 V = normalize(VIEW);					// 	View:	Already normalised
	vec3 H = normalize(L + V);
	
	// COMPONENTS DIFFUSE | AMBIENT
	float kD = 		0.30;
	float kA = 		0.01;
	float kS = 		1.0;
	
	// DIFFUSE | LAMBERT
	float dotNL = 	max(0.0, dot(N, L));
	// TOON
	float maskDiff = smoothstep(0.0, 0.01, dotNL);
	// mix (a, b, mask) , a = 0.0 >> 1.0, b = colorLight
	vec3 mixDiff = mix(vec3( shadeOpacity ), LIGHT_COLOR, vec3(maskDiff));
	vec3 diffuse = 	(kD * mixDiff) * ALBEDO * ATTENUATION;
	
	// SPECULAR
	float specular =	pow(max( dot(N, H), 0.0), glossSharp ) ;
	float maskSpec = 	smoothstep(0.01, 0.5, specular);
	
	// LIGHTS + SPECULAR
	float toggleSpec = 	float (addSpecular) ;
	vec3 totalSpec = kS * LIGHT_COLOR * ALBEDO * maskSpec * toggleSpec;
	
	float dotVN = max(dot(V, N), 0.0);
	float invertVN = 1.0 - dotVN;
	float fresnel = invertVN * float(addFresnel) * ATTENUATION * maskDiff;
	float maskFres = smoothstep(rimEdge, 0.8, fresnel) * 10.0;
	
	DIFFUSE_LIGHT = diffuse + totalSpec + ( vec3(maskFres) * rimLightColor.rgb);
	
}
