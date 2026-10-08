shader_type spatial;
render_mode unshaded; // Flat - Don't calculate any type of light

// VAR - UI Uniforms ============================================
group_uniforms BlenderLightSystem;
	uniform vec3 flatColor : source_color = vec3 (1.0); 

group_uniforms maps;
	uniform sampler2D matcapColor: source_color, hint_default_white;
	uniform sampler2D matcapSpecular: source_color, hint_default_white;
	uniform bool useSpecular;

// Called for every pixel the material is visible on.
void fragment() 
{
	// FLAT COLOR
	ALBEDO = flatColor;
	
	// MATCAP
	//ALBEDO = NORMAL;
	//ALBEDO = (NORMAL * 0.5) + 0.5;
	
	mat3 model_view = mat3(VIEW_MATRIX) * mat3(MODEL_MATRIX);
	
	// 1. Transformar la normal local al espacio de vista (View Space)
	vec3 normal_view = cross(normalize(VIEW), NORMAL);
	
	vec2 rotateVector = vec2(  normal_view.y , normal_view.x );

	
	
	// 2. Aplicar la fórmula de mapeo UV: (Normal.xy * 0.5 + 0.5)
	vec2 uv = rotateVector * 0.5 + 0.5;
	
	// 3. Muestrear la textura y asignarla al color final del objeto
	vec4 diffColor = texture(matcapColor, uv);
	vec4 specColor = texture(matcapSpecular, uv);
	
	
	vec3 textColor;
	if(useSpecular) 
		textColor = vec3 (1.0) * (flatColor * diffColor.rgb) + specColor.rgb;
	else
		textColor = vec3 (1.0) * flatColor * diffColor.rgb;
	
	ALBEDO = textColor; //pow(textColor, vec3(0.45)) * pow(textColor, vec3(2.2)) ;
}
