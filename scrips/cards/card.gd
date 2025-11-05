# --- Script de la carta ---
extends Node2D
class_name Card

# --- Nodos hijos de la carta ---
@export var front_sprite: Sprite2D
@export var back_sprite: Sprite2D
@export var opacity_sprite: Sprite2D
@export var collision_shape: CollisionShape2D
@export var card_animator: AnimationPlayer
@export var current_parent: Node2D

# --- Propiedades de la carta ---
@export var card_id: String
@export var card_type: String
@export var card_color: String
@export var card_symbol: int
@export var card_effect: String
@export var target_color: Color

# --- Estados de la carta ---
var is_selected: bool = false
var is_played: bool = false
