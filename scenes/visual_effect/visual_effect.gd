class_name VisualEffect
extends Node2D
## Representa un efecto visual en la escena, mostrando información relevante sobre el efecto aplicado.

# -- Exported Variables --
@export_group("ui")
@export var _effect_label: Label ## Muestra el valor del efecto.
@export var _effect_icon_sprite: AnimatedSprite2D ## Icono del efecto.


# -- Public Functions --
## Establece el valor y el icono del efecto visual.
func set_effect(value: int, icon: int) -> void:
	if value > 0:
		_effect_label.text = str(value)
	else:
		_effect_label.visible = false
		_effect_icon_sprite.position.x = 0
	
	_effect_icon_sprite.frame = icon