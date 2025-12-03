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
## Identificador único de la carta.
@export var card_id: String
## Tipo de la carta ([i]por ejemplo, "num", "wild", "action"[/i]).
@export var card_type: String
## Color de la carta.
@export var card_color: String
## Símbolo o número de la carta.
@export var card_symbol: int
## Efecto especial de la carta.
@export var card_effect: String
## Color objetivo para asignar o cambiar el color de la carta.
@export var target_color: Color
## Si es [param True], el efecto de la carta ya ha sido utilizado.
@export var effect_used: bool = false

# --- Public Variables ---
## Indica si la carta está seleccionada.
var is_selected: bool = false
## Indica si la carta ha sido jugada.
var is_played: bool = false