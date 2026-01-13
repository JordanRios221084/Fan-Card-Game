class_name UIEffect
extends Node2D
## Representa un efecto visual en la escena, mostrando información relevante sobre el efecto aplicado.

# -- Exported Variables --
@export_group("ui")
@export var _effect_label: Label ## Muestra el valor del efecto.
@export var _effect_label_shadow: Label ## Sombra del label del valor del efecto.
@export var _effect_icon_sprite: AnimatedSprite2D ## Icono del efecto.
@export var _effect_icon_shadow_sprite: AnimatedSprite2D ## Sombra del icono del efecto.
@export var _burst_effect: GPUParticles2D ## Efecto de explosión visual.


# -- Public Functions --
## Establece el valor y el icono del efecto visual.
func set_effect(value: int, icon: int) -> void:
	if value > 0:
		# Si hay valor significa que es un efecto "draw"
		_effect_label.text = str(value)
		_effect_label_shadow.text = str(value)
	else:
		# Si no, hay que ocultar el label y centrar el icono
		_effect_label.visible = false
		_effect_label_shadow.visible = false
		_effect_icon_sprite.position.x = 0
		_effect_icon_shadow_sprite.position.x = 0
	
	_effect_icon_sprite.frame = icon
	_effect_icon_shadow_sprite.frame = icon


## Reproduce el efecto de explosión visual.
func play_burst_effect() -> void:
	_burst_effect.z_index = 1
	_burst_effect.emitting = true