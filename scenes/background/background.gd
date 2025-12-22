class_name Background
extends ColorRect

# --- Private Variables ---
## Referencia al shader material utilizado para cambiar los colores de fondo.
var _material_shader: ShaderMaterial

func _ready() -> void:
	_material_shader = self.material as ShaderMaterial


## Cambia el color de fondo con una transición suave.
func set_background_color(target_color: Color, transition_time: float = 1.0, difference: float = 0.2) -> void:
	if target_color == _material_shader.get_shader_parameter("top_color"):
		print("-----------------------------------------------------------")
		print("El color de fondo ya es el mismo que se intenta establecer.")
		print("-----------------------------------------------------------")
		return
	
	if _material_shader:
		var color_tween: Tween = create_tween()
		color_tween.tween_property(_material_shader, "shader_parameter/top_color", target_color, transition_time)
		color_tween.parallel()
		color_tween.tween_property(_material_shader, "shader_parameter/bottom_color", target_color.darkened(difference), transition_time)
