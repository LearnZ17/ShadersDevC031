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
		
// LIGHTING FUNNCTIONS ===========================================
vec3 flatColorFunct() {
	return color;
}

vec3 MatCapFunct(vec3 normal) {
	// MATCAP Projection
	// normal -> range [-1,1.0]
	float normalScale =  0.98;
	// inverse correction
	normal = vec3(normal.x ,  -normal.y , normal.z) * normalScale; 	
	
	// range [0.0, 1.0]
	vec2 matcapUV = normal.xy * 0.5 + 0.5;
	
	// ROTATION MATRIX - CENTER ROTATION 
	float _cos = cos (angleLight * PI);
	float _sin = sin (-angleLight * PI);
	
	vec2 matcapUVRot;
	matcapUVRot.x = (normal.x * _cos) - (normal.y * _sin);
	matcapUVRot.y = (normal.x * _sin) + (normal.y * _cos); 
	matcapUVRot = matcapUVRot * 0.5 + 0.5;
	
	// MAPS
	// GAMMA : 1.0 | 0.4545 | 2.2  
	// (depends on Linear or sRGB Texture Export Configs)
	float gamma = 1.0; 
	vec3 _matcapColor = 	pow ( 
									texture( matcapColor, 	matcapUVRot ).rgb ,	
									vec3(gamma) 
								);
	vec3 _matcapSpecular = 	pow ( 
									texture( matcapSpecular, matcapUVRot ).rgb ,
									vec3(gamma) 
								);
	
	// Opt 1 : Condition
	//if (addSpecular) {	return (_matcapColor * color) + _matcapSpecular; }
	//else { return _matcapColor * color; }
	
	// Opt 2 : Ternaric
	//return addSpecular ? (_matcapColor * color) + _matcapSpecular : 
							// (_matcapColor * color);
	
	// Opt 3 : Bool to float
	return _matcapColor * color + 
			(_matcapSpecular * float(addSpecular));
}

vec3 StudioFunct(vec3 normal, vec3 view){
	
	// STUDIO LIGHTS
	// 1. White Light:
	vec3 LDIR_1 = vec3(0.0, 0.64, 0.77);
	vec3 LCOL_1 = vec3(0.5, 0.50, 0.50);
	float LSMTH_1 = 0.1;
	
	// 2. Green Light:
	vec3 LDIR_2 = vec3(-0.85, -0.36, 0.39);
	vec3 LCOL_2 = vec3(0.02, 0.06, 0.06);
	float LSMTH_2 = 0.34;

	// 3. Purple Light:
	vec3 LDIR_3 = vec3(0.76, -0.53, 0.38);
	vec3 LCOL_3 = vec3(0.06, 0.04, 0.04);
	float LSMTH_3 = 0.34;
	
	// 4. WHITE:
	vec3 LDIR_4 = vec3(0.03, 0.91, 0.4);
	vec3 LCOL_4 = vec3(0.0, 0.0, 0.0);
	float LSMTH_4 = 0.7;
	
	// ROTATION MATRIX
	float _cos = cos (angleLight * PI);
	float _sin = sin (-angleLight * PI);
	
	// (L) + ROTATION MATRIX
	LDIR_1 = normalize(vec3(LDIR_1.x * _cos - LDIR_1.z * _sin , 	
							LDIR_1.y - 0.4, 	
							LDIR_1.x * _sin + LDIR_1.z * _cos));
					
	LDIR_2 = normalize(vec3(LDIR_2.x * _cos - LDIR_2.z * _sin, 	
							LDIR_2.y - 0.4, 	
							LDIR_2.x * _sin + LDIR_2.z * _cos));
					
	LDIR_3 = normalize(vec3(LDIR_3.x * _cos - LDIR_3.z * _sin,
							LDIR_3.y - 0.4,
							LDIR_3.x * _sin + LDIR_3.z * _cos));
					
	LDIR_4 = normalize(vec3(LDIR_4.x * _cos - LDIR_4.z * _sin,
							LDIR_4.y - 0.4 ,
							LDIR_4.x * _sin + LDIR_4.z * _cos));
	
	vec3 N = normal;				//	Normal:	No normalised
	vec3 V = view;					// 	View:	Already normalised
	float GlossSharp = 32.0;		// Specular >> Bright Size >> X^2
	
	// COMPONENTS DIFFUSE | AMBIENT
	vec3 kD = 			color * 0.75;
	float kA = 			0.01;
	
	// WHITE LIGHT
	vec3 LSPEC_1 = 		normalize(vec3(.66, .66,.66));
	float dotNL_1 = 	max(dot(N, normalize(LDIR_1)), 0.0);
	vec3 H_1 = 			normalize(LDIR_1 + V);
	vec3 diffuse_1 = 	kD * LCOL_1 * dotNL_1;
	float specular_1 =	pow(max( dot(N, H_1), 0.0), GlossSharp ) ;
	
	// GREEN LIGHT
	vec3 LSPEC_2 = 		normalize ( vec3(.03, .06,.63));
	float dotNL_2 = 	max(dot(N, normalize(LDIR_2)), 0.0);
	vec3 H_2 = 			normalize(LDIR_2 + V);
	vec3 diffuse_2 = 	kD * LCOL_2 * dotNL_2;
	float specular_2 =		pow(max(dot(N, H_2), 0.0),  GlossSharp  ) ;
	
	// PURPLE LIGHT
	vec3 LSPEC_3 = 		normalize(vec3(.69, .46,.46));
	float dotNL_3 = 	max(dot(N, normalize(LDIR_3)), 0.0);
	vec3 H_3 = 			normalize(LDIR_3 + V);
	vec3 diffuse_3 = 	kD * LCOL_3 * dotNL_3;
	float specular_3 = 	pow(max( dot(N, H_3), 0.0),  GlossSharp ) ;
	
	// WHITE LIGHT
	vec3 LSPEC_4 = 		normalize(vec3(.02, .02,.02));
	float dotNL_4 = 	max(dot(N, normalize(LDIR_4)), 0.0);
	vec3 H_4 = 			normalize(LDIR_4 + V);
	vec3 diffuse_4 = 	kD * LCOL_4 * dotNL_4;
	float specular_4 = 	pow(max( dot(N, H_4), 0.0), GlossSharp) ;
	
	// LIGHTS AND SPECULAR
	float toggleSpec = 	float (addSpecular) * 3.0 ;
	vec3 L1 = diffuse_1 + (LSPEC_1 * (specular_1 * LCOL_1) * LSMTH_1) * (toggleSpec ) ;
	vec3 L2 = diffuse_2 + (LSPEC_2 * (specular_2 * LCOL_2) * LSMTH_2) * (toggleSpec ) ;
	vec3 L3 = diffuse_3 + (LSPEC_3 * (specular_3 * LCOL_3) * LSMTH_3) * (toggleSpec ) ;
	vec3 L4 = diffuse_4 + (LSPEC_4 * (specular_4 * LCOL_4) * LSMTH_4) * (toggleSpec ) ;
	
	return ( L1 + L2 + L3 + L4 );
}

// FRAGMENT =====================================================
// Called for every pixel the material is visible on.
void fragment() {
	vec3 finalColor;
	
	vec3 normal = normalize(NORMAL);  	//	Normal:	No Normalizado
	
    // 1. Transformar la normal local al espacio de vista (View Space)
    //vec3 view = cross(VIEW, normal);
	vec3 view = VIEW;					// 	View:	Ya viene normalizado
	
	// MENU SWITCH
	switch(lighting){
		case 0: // FLAT COLOR
			finalColor = flatColorFunct();
			break;
		case 1: // MATCAP 
			finalColor = MatCapFunct(normal);
			break;
		case 2: // STUDIO
			finalColor = StudioFunct(normal, view);
			break;
	}
		
	ALBEDO = finalColor; 
}
