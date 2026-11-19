shader_type spatial;

// Color base del objeto (opcional)
uniform vec3 base_color : source_color = vec3(0.05, 0.05, 0.05);

// Color y multiplicador de emisión
uniform vec3 emissive_color : source_color = vec3(1.0, 0.4, 0.1);
uniform float emissive_intensity : hint_range(0.0, 10.0) = 5.0;

void fragment() {
    ALBEDO = base_color;
    // Multiplicamos el color por la intensidad para lograr el brillo
    EMISSION = emissive_color.rgb * emissive_intensity;
}
