shader_type spatial;
render_mode ambient_light_disabled, specular_disabled;

// ===================================
// UNIFORMS
// ===================================

group_uniforms P_B_R;
	uniform sampler2D albedoMap : filter_linear_mipmap;
	uniform float alphaThreshold : hint_range(0.0, 1.0, 0.1) = 0.5
	;
	uniform sampler2D ormMap : filter_linear_mipmap;
	uniform sampler2D normalMap : filter_linear_mipmap;
	uniform float normalStrength : hint_range(0.0, 1.0, 0.1) = 1.0;
	
group_uniforms I_B_L;
	uniform sampler2D iblMap : filter_linear_mipmap;
	uniform sampler2D lutMap;
	uniform float iblStrenght : hint_range(0.0, 1.0, 0.1) = 1.0 ; 

// ========================================
// AUX MATH FUNCTONS
// ========================================

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
	// =================================================
	vec4 _albedoMap = pow(texture(albedoMap, UV), vec4(2.2));
	vec3 _normalMap = texture(normalMap, UV).rgb;
	vec3 _ormMap = texture(ormMap, UV).rgb;
	
	float _aoMap = _ormMap.r; 		// Occlusion
	float _roughMap = _ormMap.g ; 	// Roughness
	float _metalMap = _ormMap.b; 	// Metallic
	
	// =================================================
	// ALPHA SCISSORS
	// =================================================
	if (_albedoMap.a < alphaThreshold) { discard; }
	
	// =================================================
	// NORMAL (Unpacked + TBN) - Normal | IMPORTS : Textures Normal Map -> w/Detect (Disable)
	// ================================================= 
	
	vec3 normalUnpack = _normalMap * 2.0 - 1.0;
	vec3 normalIntensity = mix(vec3(0.0, 0.0, 1.0), normalUnpack, normalStrength);

	mat3 TBN = mat3(normalize(TANGENT), normalize(BINORMAL), normalize(NORMAL));
	NORMAL = normalize(TBN * normalIntensity);
	
	
	
	
	
	ALBEDO = _albedoMap.rgb;
	
}
