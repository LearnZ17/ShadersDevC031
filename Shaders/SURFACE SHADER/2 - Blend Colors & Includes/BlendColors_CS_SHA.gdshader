shader_type spatial;
render_mode unshaded;
#include "uid://df1dj5h58qtn6"

uniform float baseTile : hint_range(0.01, 5.0, 0.1);
uniform sampler2D baseMap : source_color, filter_linear_mipmap;

uniform float blendTile : hint_range(0.01, 5.0, 0.1);
uniform sampler2D blendMap : source_color, filter_linear_mipmap;

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 _baseMap = texture(baseMap, UV * baseTile).rgb;
	vec3 _blendMap = texture(blendMap, UV * blendTile).rgb;
	
	ALBEDO = blend_multiply(_baseMap, _blendMap);
}
