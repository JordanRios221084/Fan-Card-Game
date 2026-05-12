class_name Background
extends ColorRect
## Representa el fondo de la escena, ubicado detrás de todos los demás elementos visuales.


# --- Private Variables ---
## Referencia al shader material utilizado para cambiar los colores de fondo.
var material_shader: ShaderMaterial

func _ready() -> void:
	material_shader = self.material as ShaderMaterial

## Cambia el color de fondo con una transición suave.
func set_background_color(target_color: Color, transition_time: float = 0.3, difference: float = 0.7) -> void:
	if target_color == material_shader.get_shader_parameter("top_color"):
		print("-----------------------------------------------------------")
		print("El color de fondo ya es el mismo que se intenta establecer.")
		print("-----------------------------------------------------------")
		return
	
	if material_shader:
		var color_tween: Tween = create_tween()
		color_tween.tween_property(material_shader, "shader_parameter/top_color", target_color, transition_time)
		color_tween.parallel()
		color_tween.tween_property(material_shader, "shader_parameter/bottom_color", target_color.darkened(difference), transition_time)


## Invertir la dirección de la onda del fondo.
func invert_wave_direction() -> void:
	if material_shader:
		var current_direction: float = material_shader.get_shader_parameter("wave_dir")
		var direction_tween: Tween = create_tween()
		direction_tween.tween_property(material_shader, "shader_parameter/wave_dir", -current_direction, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
