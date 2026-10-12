shader_type spatial;
render_mode unshaded; // Flat - Don't calculate any type of light

// VAR - UI Uniforms ============================================
group_uniforms BlenderLightSystem;
	group_uniforms BlenderLightSystem.Maps;
		uniform sampler2D matcapColor: source_color, hint_default_white;
		uniform sampler2D matcapSpecular: source_color, hint_default_white;
	
	group_uniforms BlenderLightSystem.Lighting;
		uniform int lighting : hint_enum("Flat :0, MatCap:1, Studio :2") = 0;

	group_uniforms BlenderLightSystem.Properties;
		// Base Color
		uniform vec3 color : source_color = vec3 (1.0); 
		// Specular
		uniform bool addSpecular = true;
		// Angle Light
		uniform float angleLight : hint_range(-1.0, 1.0, 0.1);
		
			
			
vec3 flatColorFunct() {
	return color;
}

vec3 MatCapFunct(vec3 _normalView) {
	// MATCAP Projection
	// _normalView -> range [-1,1.0]
	float normalScale = 0.98;
	_normalView = vec3(_normalView.x, -_normalView.y, _normalView.z) * normalScale; 	// inverse correction
	
	vec2 matcapUV = _normalView.xy * 0.5 + 0.5;	 		// range [0.0, 1.0]
	
	// ROTATION MATRIX - CENTER ROTATION 
	float _cos = cos (-angleLight * PI);
	float _sin = sin (-angleLight * PI);
	
	vec2 matcapUVRot;
	matcapUVRot.x = (_normalView.x * _cos) - (_normalView.y * _sin);
	matcapUVRot.y = (_normalView.x * _sin) + (_normalView.y * _cos); 
	matcapUVRot = matcapUVRot * 0.5 + 0.5;
	
	// MAPS
	float gamma = 1.0; // 0.4545 | 2.2  (depends on Linear or sRGB Texture Export Configs)
	vec3 _matcapColor = 	pow ( texture( matcapColor, 	matcapUVRot ).rgb ,	vec3(gamma) );
	vec3 _matcapSpecular = 	pow ( texture( matcapSpecular, 	matcapUVRot ).rgb ,	vec3(gamma) );
	
	// Opt 1 : Condition
	//if (addSpecular) {	return (_matcapColor * color) + _matcapSpecular; }
	//else { return _matcapColor * color; }
	
	// Opt 2 : Ternaric
	//return addSpecular ? (_matcapColor * color) + _matcapSpecular : 
							//(_matcapColor * color);
	
	// Opt 3 : Bool to float
	return _matcapColor * color + (_matcapSpecular * float(addSpecular));
}

// Called for every pixel the material is visible on.
void fragment() 
{
	vec3 finalColor = vec3(1.0);
	
	// FLAT COLOR
	if (lighting == 0) 
		finalColor = flatColorFunct();
		
	// MATCAP 
	if (lighting == 1 )
		finalColor = MatCapFunct(NORMAL);	
	
	float _cos = cos (angleLight * PI);
	float _sin = cos (angleLight * PI);
	
	// STUDIO LIGHTS
	// White Light:
	vec3 LDIR_1 = vec3(0.0, 0.64, 0.77);
	vec3 LCOL_1 = vec3(0.5, 0.50, 0.50);

	// Green Light:
	vec3 LDIR_2 = vec3(-0.85, -0.36, 0.39);
	vec3 LCOL_2 = vec3(0.02, 0.06, 0.06);

	//Purple Light:
	vec3 LDIR_3 = vec3(0.76, -0.53, 0.39);
	vec3 LCOL_3 = vec3(0.06, 0.04, 0.04);
	
	LDIR_1 = vec3(LDIR_1.x * _cos - LDIR_1.z * _sin, 	LDIR_1.y, 	LDIR_1.x * _sin * LDIR_1.z * _cos);
	LDIR_2 = vec3(LDIR_2.x * _cos - LDIR_2.z * _sin, 	LDIR_2.y, 	LDIR_2.x * _sin * LDIR_2.z * _cos);
	LDIR_3 = vec3(LDIR_3.x * _cos - LDIR_3.z * _sin, 	LDIR_3.y, 	LDIR_3.x * _sin * LDIR_3.z * _cos);
	
	vec3 N = normalize(NORMAL);			//	Normal:	No Normalizado
	vec3 V = VIEW;						// 	View:	Ya viene normalizado
	float GlossSharp = 256.0;			// Specular >> Brillo Size
	
	// COMPONENTS
	vec3 kD = color * vec3(0.5);
	float kA = 0.015;
	
	// WHITE LIGHT
	float dotNL_1 = max(0.0, dot(N, normalize(LDIR_1)));
	vec3 H_1 = normalize(LDIR_1 + V);
	vec3 diffuse_1 = kD + LCOL_1 * dotNL_1;
	float specular_1 = pow(max(0.0, dot(N, H_1)), GlossSharp);
	
	// GREEN LIGHT
	float dotNL_2 = max(0.0, dot(N, normalize(LDIR_2)));
	vec3 H_2 = normalize(LDIR_2 + V);
	vec3 diffuse_2 = kD + LCOL_2 * dotNL_2;
	float specular_2 = pow(max(0.0, dot(N, H_2)), GlossSharp);
	
	// PURPLE LIGHT
	float dotNL_3 = max(0.0, dot(N, normalize(LDIR_3)));
	vec3 H_3 = normalize(LDIR_3 + V);
	vec3 diffuse_3 = kD + LCOL_3 * dotNL_3;
	float specular_3 = pow(max(0.0, dot(N, H_3)), GlossSharp);
	
	vec3 L1 = diffuse_1 * LCOL_1 + specular_1;
	vec3 L2 = diffuse_2 * LCOL_2 + specular_2;
	vec3 L3 = diffuse_3 * LCOL_3 + specular_3;
	
	if (lighting == 2)
		finalColor = L1;	
		
	ALBEDO = finalColor; 

}
