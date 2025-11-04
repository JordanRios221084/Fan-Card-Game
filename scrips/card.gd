# --- Script de la carta ---
extends Node2D
class_name Card

# --- Propiedades de la carta ---
@export var card_id: String
@export var card_type: String
@export var card_color: String
@export var card_symbol: int
@export var card_effect: String

var target_color: Color

# --- Estados de la carta ---
var is_selected: bool = false
var is_played: bool = false

# --- Nodos hijos ---
var front_sprite: Sprite2D
var back_sprite: Sprite2D
var opacity_sprite: Sprite2D
var collision_shape: CollisionShape2D
var card_animator: AnimationPlayer
var current_parent: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	front_sprite = $FrontSprite
	back_sprite = $BackSprite
	opacity_sprite = $OpacitySprite
	collision_shape = $Area2D/CollisionShape2D
	card_animator = $AnimationPlayer
