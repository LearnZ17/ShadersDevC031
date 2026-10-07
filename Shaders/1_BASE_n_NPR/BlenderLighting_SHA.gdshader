shader_type spatial;
render_mode unshaded; // Flat - Don't calculate any type of light

// VAR - UI Uniforms ============================================
group_uniforms BlenderLightSystem;
uniform vec3 flatColor : source_color = vec3 (1.0);

// Called for every pixel the material is visible on.
void fragment() 
{
	ALBEDO = flatColor;
}
