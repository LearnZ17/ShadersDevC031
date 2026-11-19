shader_type spatial;

// ===================================
// UNIFORMS
group_uniforms P_B_R;
	uniform sampler2D albedoMap : source_color, filter_linear_mipmap;
	uniform float alphaClip : hint_range(0.0, 1.0, 0.1) = 0.5;
	
	uniform sampler2D ormMap : filter_linear_mipmap;
	uniform sampler2D normalMap : hint_normal, filter_linear_mipmap;
	uniform float normalIntensity : hint_range(0.0, 5.0, 0.01) = 1.0;
	
void fragment() {
	// Called for every pixel the material is visible on.
	// SANPLING
	vec4 _albedoMap = texture(albedoMap, UV);
	vec3 _normalMap = texture(normalMap, UV).rgb;
	vec3 _ormMap = texture(ormMap, UV).rgb;
	
	// OUTPUT BUFFERS
	ALBEDO = _albedoMap.rgb;
	AO = _ormMap.b;
	
	ROUGHNESS = _ormMap.g;
	METALLIC = _ormMap.b;
	
	NORMAL_MAP = _normalMap;
	NORMAL_MAP_DEPTH = normalIntensity;
	
	ALPHA = _albedoMap.a;
	ALPHA_SCISSOR_THRESHOLD = alphaClip;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
