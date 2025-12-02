extends Node2D
class_name Card
## [b]Descripción:[/b] Nodo Card que representa una carta. [br]
## Contiene propiedades y nodos hijos relacionados con la carta.

# --- Nodos hijos de la carta ---
@export var front_sprite: Sprite2D ## Nodo Sprite2D para la cara frontal de la carta
@export var back_sprite: Sprite2D ## Nodo Sprite2D para la cara trasera de la carta
@export var opacity_sprite: Sprite2D ## Nodo Sprite2D para la opacidad de la carta
@export var collision_shape: CollisionShape2D ## Nodo CollisionShape2D para la colisión de la carta
@export var card_animator: AnimationPlayer ## Nodo AnimationPlayer para las animaciones de la carta
@export var current_parent: Node2D ## Nodo Node2D que representa el padre actual de la carta

# --- Propiedades de la carta ---
@export var card_id: String ## Identificador único de la carta
@export var card_type: String ## Tipo de la carta (por ejemplo, número, acción)
@export var card_color: String ## Color de la carta
@export var card_symbol: int ## Símbolo o número de la carta
@export var card_effect: String ## Efecto especial de la carta
@export var target_color: Color ## Color objetivo para efectos que cambian el color
@export var effect_used: bool = false ## Indica si el efecto de la carta ha sido usado

# --- Estados de la carta ---
var is_selected: bool = false ## Indica si la carta está seleccionada
var is_played: bool = false ## Indica si la carta ha sido jugada
