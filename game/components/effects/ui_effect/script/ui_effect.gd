class_name UIEffect
extends Node2D
## Representa un efecto visual en la escena, mostrando información relevante sobre el efecto aplicado.

# -- Exported Variables --
@export_group("ui")
@export var effect_label: Label ## Muestra el valor del efecto.
@export var effect_label_shadow: Label ## Sombra del label del valor del efecto.
@export var effect_icon_sprite: AnimatedSprite2D ## Icono del efecto.
@export var effect_icon_shadow_sprite: AnimatedSprite2D ## Sombra del icono del efecto.
@export var burst_effect: GPUParticles2D ## Efecto de explosión visual.

# -- Public Functions --
## Establece el valor y el icono del efecto visual.
func set_effect(value: int, icon: int) -> void:
	if value > 0:
		# Si hay valor significa que es un efecto "draw"
		effect_label.text = str(value)
		effect_label_shadow.text = str(value)
	else:
		# Si no, hay que ocultar el label y centrar el icono
		effect_label.visible = false
		effect_label_shadow.visible = false

		effect_icon_sprite.position = Vector2.ZERO
		effect_icon_shadow_sprite.position = Vector2.ZERO
	
	effect_icon_sprite.frame = icon
	effect_icon_shadow_sprite.frame = icon


## Reproduce el efecto de explosión visual.
func play_burst_effect() -> void:
	burst_effect.z_index = 1
	burst_effect.emitting = true