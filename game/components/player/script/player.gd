class_name Player
extends Node2D
## Jugador que contiene la lógica para manejar su mano de cartas.
##
## Contiene funciones para añadir cartas, ordenar la mano y calcular posiciones.


# --- Constants
## Tiempo objetivo para sincronizar estados.
const _WAIT_TIME_SECONDS: float = 0.25


# --- Exports ---
@export_group("Status")
## Indica si es el turno del jugador.
@export var is_turn: bool = false
## Indica si el jugador es humano.
@export var is_human: bool = false
## Muestra las cartas para el modo DEBUG
@export var show_cards: bool = false

@export_group("Components")
## Contenedor visual de las cartas
@export var cards_container: CardsContainer
## Controlador del jugador (Puede ser IA o Humano)
@export var self_cotroller: Controller


# --- Public Variables ---
## Arreglo que contiene las cartas en la mano del jugador.
var current_hand: Array[Card] = []


# --- Engine Functions ---
func _ready() -> void:
	self_cotroller.set_player(self)


# --- Public Functions ---
## Añade una carta a la mano del jugador y actualiza su posición. [br]
## Si el jugador es humano, reproduce una animación de voltear la carta. [br]
## Si es el turno del jugador, ordena las cartas automáticamente.
func add_card_to_hand(new_card: Card) -> void:
	new_card.reparent(cards_container)

	current_hand.append(new_card)
	new_card.current_parent = cards_container
	
	if is_human or show_cards:
		new_card.card_animator.play("flip_card")
	
	if cards_container.auto_sort_cards:
		cards_container.sort_cards(current_hand)
	
	cards_container.allign_cards(current_hand)
	
	await get_tree().create_timer(_WAIT_TIME_SECONDS).timeout


## Elimina una carta de la mano del jugador y actualiza la posición de las cartas restantes.
func play_a_card(card_to_play: Card) -> void:
	current_hand.erase(card_to_play)
	cards_container.allign_cards(current_hand)