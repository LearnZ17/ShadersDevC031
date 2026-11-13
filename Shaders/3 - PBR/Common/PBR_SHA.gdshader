shader_type spatial;
render_mode ambient_light_disabled, specular_disabled;

// ===================================
// UNIFORMS
group_uniforms P_B_R;
	uniform sampler2D albedoMap : filter_linear_mipmap;
	uniform float alphaThreshold : hint_range(0.0, 1.0, 0.01) = 0.5;
	uniform sampler2D ormMap : filter_linear_mipmap;
	uniform sampler2D normalMap : filter_linear_mipmap;
	uniform float normalStrength : hint_range(0.0, 5.0, 0.01) = 1.0;
	uniform sampler2D emissionMap : filter_linear_mipmap;
	uniform float emissionIntensity : hint_range(0.0, 10.0, 0.1) = 0.0;
	
group_uniforms I_B_L;
	uniform sampler2D iblMap : filter_linear_mipmap;
	uniform sampler2D lutMap;
	uniform float iblStrenght : hint_range(0.0, 5.0, 0.1) = 1.0 ; 

// ========================================
// AUX MATH FUNCTONS

// F-Físico: Materiales con rugosidad » madera, piedra, etc.
vec3 F_SchlickRoughness(float cosTheta, vec3 F0, float roughness) {
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

// ------------ COORDENADAS DE UVs A POLARES ------------
vec2 equirect_to_polar(vec3 dir) {
    vec3 d = normalize(dir);
    float phi = acos(clamp(d.y, -1.0, 1.0));
    float theta = atan(d.z, d.x) + PI;
    return vec2(theta / (2.0 * PI), phi / PI);
}

void fragment() {
	// =================================================
	// SAMPLING TEXTURES
	vec4 _albedoMap = 	pow(texture(albedoMap, UV), vec4(2.2));
	vec3 _normalMap = 	texture(normalMap, UV).rgb;
	vec3 _ormMap = 		texture(ormMap, UV).rgb;
	vec3 _emissiveMap = texture(emissionMap, UV).rgb;
	
	float _aoMap = 		_ormMap.r; 		// Occlusion
	float _roughMap = 	_ormMap.g ; 	// Roughness
	float _metalMap = 	_ormMap.b; 		// Metallic
	
	// =================================================
	// ALPHA SCISSORS
	if (_albedoMap.a < alphaThreshold) { discard; }
	
	// =================================================
	// NORMAL (Unpacked + TBN) - Normal | IMPORTS : Textures Normal Map -> w/Detect (Disable)	
	vec3 normalUnpack = 	_normalMap * 2.0 - 1.0;
	vec3 normalIntensity = 	mix(vec3(0.0, 0.0, 1.0), normalUnpack, normalStrength);
	mat3 TBN =				mat3(normalize(TANGENT), normalize(BINORMAL), normalize(NORMAL));
	NORMAL = 				normalize(TBN * normalIntensity);
	
	// CALCULO DE ILUMINACION BASADO EN IMAGEN (IBL & COOK-TORRANCE)

	// ----- Componentes
	float dotNV = 		max(0.0, dot(NORMAL, VIEW));
	vec3 reflectNV = 	reflect(NORMAL, VIEW);
	float roughRead = 	sqrt(_roughMap);

	// ----- NO Convolucionado » Hack
	float maxLod_Hack = 7.0;       //1024x512px: (1024 = 10mip, 512 = 8) » 8.5
	float iblStrength_hack = 2.0;
	iblStrength_hack = mix (2.0, 5.0, _metalMap);

	// ----- Simular GI en Sombras » Hack
	//ALBEDO = _albedoMap.rgb * iblStrength_hack;
	//EMISSION = ALBEDO * mix (0.5, 1.0, _metalMap);

	// ----- IBL » Irradiance Diffuse (EXR » normal perturbado).
	vec3 ibl_irradiance = textureLod(iblMap, equirect_to_polar(NORMAL), maxLod_Hack).rgb;
	ibl_irradiance *= vec3(iblStrenght * iblStrength_hack);

	// ----- IBL » Radiance Specular (EXR » reflect).
	vec3 ibl_radiance = textureLod(iblMap, equirect_to_polar(reflectNV), roughRead * maxLod_Hack).rgb;
	ibl_radiance *= vec3(iblStrenght * iblStrength_hack);

	// ----- Geometria de vision en respuesta al Fresnel
	// F0 » reflectancia base (4% » Dialectricos, 70-96% - AlbedoColor » Metalic).
	vec3 F0 = mix( vec3(0.04), _albedoMap.rgb, 1.0-_metalMap);

	// Fresnel atenuado por la rugosidad del superficie
	vec3 F_rough = F_SchlickRoughness( dotNV, F0, roughRead ) ;
	
	
	// ----- Conservacion de Energia (Coeficiente de kS y kD).
	vec3 kS = F_rough;
	vec3 kD = (1.0 - kS) * (1.0 - _metalMap);

	// ----- Composicion IBL
	// Irradiance Diffuse
	vec3 indirectDiffuse = ibl_irradiance * _albedoMap.rgb * kD;

	// Radiance Specular
	vec2 _lutMap = texture( lutMap, vec2(dotNV, roughRead) ).rg;
	vec3 indirectSpecular = ibl_radiance * (F0 * _lutMap.x + _lutMap.y);

	// ======================================
	//ALBEDO = ibl_radiance;
	//ALBEDO = indirectDiffuse;
	//ALBEDO = indirectSpecular;
	ALBEDO = (indirectDiffuse + indirectSpecular) * _aoMap;
	
	
	EMISSION = ALBEDO * mix (0.5, 1.0, _metalMap) + (_emissiveMap * emissionIntensity);
}
