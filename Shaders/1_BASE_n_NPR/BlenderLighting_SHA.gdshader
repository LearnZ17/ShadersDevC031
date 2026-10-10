shader_type spatial;
render_mode unshaded; // Flat - Don't calculate any type of light

// VAR - UI Uniforms ============================================


group_uniforms BlenderLightSystem;

	uniform int modo : hint_enum("FlatColor:0,MatCap:1") = 0;
	
	uniform vec3 flatColor : source_color = vec3 (1.0); 

group_uniforms maps;
	uniform sampler2D matcapColor: source_color, hint_default_white;
	uniform sampler2D matcapSpecular: source_color, hint_default_white;
	uniform bool useSpecular;

// Called for every pixel the material is visible on.
void fragment() 
{
	vec3 finalColor = vec3(1.0);
	
	// FLAT COLOR
	if (modo == 0) 
		finalColor =  flatColor;
	
	// MATCAP
	// 1. Transformar la normal local al espacio de vista (View Space)
	vec3 normal_view = cross(normalize(VIEW), NORMAL);
	
	// 		1.1 Rotation Fix
	vec2 rotateVector = vec2(  normal_view.y , normal_view.x );

	// 2. Aplicar la fórmula de mapeo UV: (Normal.xy * 0.5 + 0.5)
	vec2 uv = rotateVector * 0.5 + 0.5;
	
	// 3. Muestrear la textura y asignarla al color final del objeto
	vec3 diffColor = texture(matcapColor, uv).rgb;
	vec3 gamma_diffColor = pow(diffColor, vec3(.45)) * pow(diffColor, vec3(2.2)) ;
	vec3 specColor = texture(matcapSpecular, uv).rgb;
	
	
	vec3 textColor;
	if(useSpecular) 
		textColor = vec3 (1.0) * (flatColor * diffColor) + specColor;
	else
		textColor = vec3 (1.0) * flatColor * diffColor;
		
	if (modo == 1 )
		finalColor = textColor;
	
	ALBEDO = finalColor; //pow(textColor, vec3(0.45)) * pow(textColor, vec3(2.2)) ;
}
