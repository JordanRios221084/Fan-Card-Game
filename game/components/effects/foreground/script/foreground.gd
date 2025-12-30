class_name Foreground
extends ColorRect
## Representa el primer plano de la escena, ubicado por encima de todos los demás elementos visuales.


# --- Public Functions ---
## Reproduce un efecto de onda expansiva en el primer plano.
func play_shockwave_effect(center_pos: Vector2) -> void:
	var center: Vector2 = center_pos / get_rect().size
	var shockwave_material: ShaderMaterial = material

	if shockwave_material is ShaderMaterial:
		shockwave_material.set_shader_parameter("center", center)
		shockwave_material.set_shader_parameter("radius", 0.0)

		var shock_tween: Tween = create_tween()
		shock_tween.tween_property(shockwave_material, "shader_parameter/radius", 2.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
