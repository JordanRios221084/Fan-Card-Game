# --- Script de la baraja ---
extends Node2D
class_name Deck

# --- Constantes ---
const CARD_SCENCE_PATH: String = "res://scenes/cards/card.tscn"

# --- Nodos ---
@export var deck_sprite: Sprite2D
@export var deck_collision_shape: CollisionShape2D

# --- Baraja actual ---
var current_deck: Array = []

# --- Función para robar una carta de la baraja ---
func draw_card() -> Card:
	# Mezclar la baraja antes de robar una carta
	current_deck.shuffle()

	# Comprobar si la baraja está vacía
	if current_deck.size() == 0:
		push_warning("La baraja está vacía. No se puede robar una carta.")
		return null
	
	# Obtener los valores de la carta robada
	var card_drawn_values: CardValues = current_deck.pop_back()
	var card_sprite_path: String = "res://assets/sprites/" + card_drawn_values.card_type + ".png"

	# Instanciar una nueva carta
	var card_scene: PackedScene = preload(CARD_SCENCE_PATH)
	var new_card: Card = card_scene.instantiate() as Card

	# Añadir la carta al nodo Deck
	self.add_child(new_card)

	# Configurar las propiedades de la carta
	CardBuilder.build_card(card_drawn_values, new_card, card_sprite_path)

	# Devolver la nueva carta
	return new_card
