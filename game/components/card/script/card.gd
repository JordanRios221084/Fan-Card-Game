class_name Card
extends Node2D
## Este nodo representa una carta en el juego.
##
## Sus propiedades incluyen identificadores, tipo, color, símbolo, efectos y estados.
## También contiene referencias a sus nodos hijos para la representación visual y la interacción.


# --- Signals ---
signal mouse_on_card(card: Card)
signal mouse_off_card(card: Card)


# --- Export Variables ---
@export_group("References")
@export var sprites: Node2D ## Contiene los sprites de la carta.
@export var front_sprite: Sprite2D ## Textura de la cara frontal de la carta.
@export var back_sprite: Sprite2D ## Textura de la cara trasera de la carta.
@export var opacity_sprite: Sprite2D ## Textura para la opacidad de la carta.
@export var collision_shape: CollisionShape2D ## [CollisionShape2D] para la colisión de la carta.
@export var card_animator: AnimationPlayer ## [AnimationPlayer] para las animaciones de la carta.
@export var current_parent: Node2D ## [Node2D] que es padre actual de la carta.

@export_group("Properties")
@export var values: CardValues ## Valores de la carta

# --- Constans ---
## Estructura de datos para los colores de la carta.
## Los colores disponibles son: "red", "blue", "green", "yellow", "black".
const COLOR_MAP: Dictionary = {
	"red": Color(0.996, 0, 0),
	"blue": Color(0.011, 0.352, 0.886),
	"green": Color(0.001, 0.729, 0.011),
	"yellow": Color(1, 0.792, 0.007),
	"black": Color.BLACK
}

# --- Variables ---
var is_selected: bool = false ## Indica si la carta está seleccionada.
var is_played: bool = false ## Indica si la carta ha sido jugada.
var is_effect_used: bool = false ## Indica si el efecto de la carta ya ha sido utilizado.





# -------------------- Setters --------------------

## Se encarga de inicializar el color de la carta
func set_card_color(color_name: String) -> void:
	values.target_color = COLOR_MAP[color_name]

	if front_sprite.material:
		# Duplicar el material para evitar modificar el original
		var temp_shader_material: ShaderMaterial = front_sprite.material.duplicate() as ShaderMaterial
		temp_shader_material.set_shader_parameter("target_color", values.target_color)
		front_sprite.material = temp_shader_material





# -------------------- Getters --------------------

## Devuelve el efecto de la carta.
func get_card_effect() -> String:
	return values.effect


## Devuelve el color de la carta.
func get_card_color() -> String:
	return values.color


## Devuelve el símbolo de la carta.
func get_card_symbol() -> int:
	return values.symbol





func _on_area_2d_mouse_entered() -> void:
	mouse_on_card.emit(self)


func _on_area_2d_mouse_exited() -> void:
	mouse_off_card.emit(self)