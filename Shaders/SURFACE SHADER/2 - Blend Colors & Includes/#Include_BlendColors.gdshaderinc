uniform int blend_mode : hint_enum(
	"Multiply",
	"Screen",
	"Darken",
	"Lighten",
	"Difference",
	"Exclusion",
	"Overlay",
	"Hard Light",
	"Soft Light",
	"Color Dodge",
	"Linear Dodge",
	"Burn",
	"Linear Burn"
) = 0;

// 1. Multiply
vec3 blend_multiply(vec3 base, vec3 blend) {
	return base * blend;
}

// 2. Screen
vec3 blend_screen(vec3 base, vec3 blend) {
	return vec3(1.0) - (vec3(1.0) - base) * (vec3(1.0) - blend);
}

// 3. Darken
vec3 blend_darken(vec3 base, vec3 blend) {
	return min(base, blend);
}

// 4. Lighten
vec3 blend_lighten(vec3 base, vec3 blend) {
	return max(base, blend);
}

// 5. Difference
vec3 blend_difference(vec3 base, vec3 blend) {
	return abs(base - blend);
}

// 6. Exclusion
vec3 blend_exclusion(vec3 base, vec3 blend) {
	return (base + blend - 2.0) * base * blend;
}

// 7. Overlay
vec3 blend_overlay(vec3 base, vec3 blend) {
	return mix(
		2.0 * base * blend,
		vec3(1.0) - 2.0 * (vec3(1.0) - base) * (vec3(1.0) - blend),
		step(0.5, base)
	);
}

// 8. Hard Light
vec3 blend_hard_light(vec3 base, vec3 blend) {
	return mix(
		2.0 * base * blend,
		vec3(1.0) - 2.0 * (vec3(1.0) - base) * (vec3(1.0) - blend),
		step(0.5, blend)
	);
}

// 9. Soft Light
vec3 blend_soft_light(vec3 base, vec3 blend) {
	vec3 dark = 2.0 * base * blend + base * base * (vec3(1.0) - 2.0 * blend);
	vec3 light = sqrt(base) * (2.0 * blend - vec3(1.0)) + (2.0 * base) * (vec3(1.0) - blend);
	return mix(dark, light, step(0.5, blend));
}

// 10. Color Dodge
vec3 blend_color_dodge(vec3 base, vec3 blend) {
	return base / max(vec3(1.0) - blend, vec3(0.0001));
}

// 11. Linear Dodge (Add)
vec3 blend_linear_dodge(vec3 base, vec3 blend) {
	return base + blend;
}

// 12. Burn (Color Burn)
vec3 blend_burn(vec3 base, vec3 blend) {
	return vec3(1.0) - (vec3(1.0) - base) / max(blend, vec3(0.0001));
}

// 13. Linear Burn
vec3 blend_linear_burn(vec3 base, vec3 blend) {
	return base + blend - vec3(1.0);
}

// Apply blend
vec3 apply_blend(int mode, vec3 base, vec3 blend) {
	switch (mode) {
		case 0: return blend_multiply(base, blend);
		case 1: return blend_screen(base, blend);
		case 2: return blend_darken(base, blend);
		case 3: return blend_lighten(base, blend);
		case 4: return blend_difference(base, blend);
		case 5: return blend_exclusion(base, blend);
		case 6: return blend_overlay(base, blend);
		case 7: return blend_hard_light(base, blend);
		case 8: return blend_soft_light(base, blend);
		case 9: return blend_color_dodge(base, blend);
		case 10: return blend_linear_dodge(base, blend);
		case 11: return blend_burn(base, blend);
		case 12: return blend_linear_burn(base, blend);
		default: return blend_multiply(base, blend);
	}
}
