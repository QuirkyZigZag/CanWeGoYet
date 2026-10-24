extends MeshInstance3D

const MIN_ABERRATION: float = 0.0
const MAX_ABERRATION: float = 0.2

func _process(delta: float) -> void:
	var battery: float = float(GameState.social_battery)
	var t: float = clamp(battery / 100.0, 0.0, 1.0)
	var mapped_aberration: float = lerp(MAX_ABERRATION, MIN_ABERRATION, t)
	
	# Try material_override first
	if material_override and material_override is ShaderMaterial:
		var shader_mat: ShaderMaterial = material_override
		shader_mat.set_shader_parameter("aberration_strength", mapped_aberration)
		return  # done

	# If no material_override, update each surface
	for i in get_surface_override_material_count():
		var mat = get_surface_override_material(i)
		if mat and mat is ShaderMaterial:
			mat.set_shader_parameter("aberration_strength", mapped_aberration)
