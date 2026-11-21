shader_type spatial;
//render_mode unshaded;
#include "uid://df1dj5h58qtn6"

uniform float baseTile : hint_range(0.01, 5.0, 0.1);
uniform sampler2D baseMap : source_color, filter_linear_mipmap;

uniform float blendTile : hint_range(0.01, 5.0, 0.1);
uniform sampler2D blendMap : source_color, filter_linear_mipmap;

uniform float alphaClip : hint_range(0.0, 1.0, 0.1) = 0.5;
	
uniform sampler2D ormMap : filter_linear_mipmap;
uniform sampler2D normalMap : hint_normal, filter_linear_mipmap;
uniform float normalIntensity : hint_range(0.0, 5.0, 0.01) = 1.0;

uniform sampler2D emissiveMap : source_color, filter_linear_mipmap;

void fragment() {
	// SANPLING
	vec4 _baseMap = texture(baseMap, UV * baseTile);
	vec4 _blendMap = texture(blendMap, UV * blendTile);
	
	vec3 _normalMap = texture(normalMap, UV).rgb;
	vec3 _ormMap = texture(ormMap, UV).rgb;
	vec3 _emissiveMap = texture(emissiveMap, UV).rgb;
	
	// OUTPUT BUFFERS
	ALBEDO = apply_blend(blend_mode, _baseMap.rgb, _blendMap.rgb);
	//ALBEDO = _baseMap.rgb;
	
	//AO = _ormMap.b;
	
	ROUGHNESS = _ormMap.g;
	METALLIC = _ormMap.b;
	
	NORMAL_MAP = _normalMap;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	NORMAL_MAP_DEPTH = normalIntensity;
	
	ALPHA = _baseMap.a;// * _blendMap.a;
	//ALPHA_SCISSOR_THRESHOLD = alphaClip;
	
	EMISSION = _emissiveMap * 2.2;
}