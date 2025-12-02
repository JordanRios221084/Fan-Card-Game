# --- Script de la baraja ---
extends Node2D
class_name Deck
## [b]Descripción:[/b] Nodo Deck que representa la baraja del juego. [br]
## Contiene funciones para manejar la baraja y robar cartas. [br]

# --- Constantes ---
const CARD_SCENCE_PATH: String = "res://scenes/card/card.tscn" ## Ruta al recurso de la escena de la carta.

# --- Nodos ---
@export var deck_sprite: Sprite2D ## Nodo Sprite2D que representa la imagen de la baraja
@export var deck_collision_shape: CollisionShape2D ## Nodo CollisionShape2D para la detección de colisiones de la baraja

# --- Baraja actual ---
var current_deck: Array = [] ## Array que contiene las cartas actuales en la baraja.

## Pertenece a: [Deck] [br]
## [b]Descripción:[/b] Función para robar una carta de la baraja. [br]
## Mezcla la baraja, comprueba si está vacía y crea una nueva carta si es posible. [br]
## Devuelve la carta robada o null si la baraja está vacía.
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
