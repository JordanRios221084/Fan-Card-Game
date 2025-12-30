class_name Card
extends Node2D
## Este nodo representa una carta en el juego.
##
## Sus propiedades incluyen identificadores, tipo, color, símbolo, efectos y estados.
## También contiene referencias a sus nodos hijos para la representación visual y la interacción.

# --- Export Variables ---
@export_group("References")
## Textura de la cara frontal de la carta.
@export var front_sprite: Sprite2D
## Textura de la cara trasera de la carta.
@export var back_sprite: Sprite2D
## Textura para la opacidad de la carta.
@export var opacity_sprite: Sprite2D
## [CollisionShape2D] para la colisión de la carta.
@export var collision_shape: CollisionShape2D
## [AnimationPlayer] para las animaciones de la carta.
@export var card_animator: AnimationPlayer
## [Node2D] que es padre actual de la carta.
@export var current_parent: Node2D

@export_group("Properties")
## Valores de la carta
@export var values: CardValues

# --- Private Constans ---
## Estructura de datos para los colores de la carta.
## Los colores disponibles son: "red", "blue", "green", "yellow", "black".
const _COLOR_MAP: Dictionary = {
	"red": Color(0.996, 0, 0),
	"blue": Color(0.011, 0.352, 0.886),
	"green": Color(0.001, 0.729, 0.011),
	"yellow": Color(1, 0.792, 0.007),
	"black": Color.BLACK
}

# --- Public Variables ---
## Indica si la carta está seleccionada.
var is_selected: bool = false
## Indica si la carta ha sido jugada.
var is_played: bool = false
## Indica si el efecto de la carta ya ha sido utilizado.
var is_effect_used: bool = false


# --- Public Functions ---
## Se encarga de inicializar el color de la carta
func set_card_color(color_name: String) -> void:
	values.target_color = _COLOR_MAP[color_name]

	if front_sprite.material:
		# Duplicar el material para evitar modificar el original
		var temp_shader_material: ShaderMaterial = front_sprite.material.duplicate() as ShaderMaterial
		temp_shader_material.set_shader_parameter("target_color", values.target_color)
		front_sprite.material = temp_shader_material
