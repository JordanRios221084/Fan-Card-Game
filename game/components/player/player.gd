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
## Indica si el jugador ha declarado "UNO".
@export var has_called_uno: bool = false

@export_group("Components")
## Contenedor visual de las cartas
@export var cards_container: CardsContainer
## Controlador del jugador (Puede ser IA o Humano)
@export var self_controller: Controller


# --- Engine Functions ---
func _ready() -> void:
	if self_controller is ManualController:
		var player_controller: ManualController = self_controller as ManualController
		cards_container.card_selected.connect(player_controller._on_card_mouse_entered_card)
		cards_container.card_deselected.connect(player_controller._on_card_mouse_exited_card)

		is_human = true
	else:
		is_human = false


# --- Functions ---
## Añade una carta a la mano del jugador y actualiza su posición. [br]
## Si el jugador es humano, reproduce una animación de voltear la carta. [br]
## Si es el turno del jugador, ordena las cartas automáticamente.
func add_card_to_hand(new_card: Card) -> void:
	cards_container.insert_card_to_hand(new_card)

	if is_turn:
		CardManager.set_card_opacity(new_card, true)
	
	if is_turn and is_human:
		new_card.collision_shape.disabled = false

	if show_cards or is_human:
		new_card.flip_card()
	
	if is_human:
		new_card.add_to_group("player_cards")
	else:
		new_card.add_to_group("opponent_cards")
	
	cards_container.allign_cards()
	
	await get_tree().create_timer(_WAIT_TIME_SECONDS).timeout


## Elimina una carta de la mano del jugador y actualiza la posición de las cartas restantes. [br]
## [Param card_to_play]: Carta que se va a eliminar de la mano.
func play_a_card(card_to_play: Card) -> void:
	card_to_play.collision_shape.disabled = true
	cards_container.current_hand.erase(card_to_play)
	cards_container.allign_cards()


## Procesa el turno del jugador llamando a su controlador asociado. [br]
## Utiliza la función [Controller.try_to_process_turn] del controlador.
func process_turn() -> void:
	self_controller.try_to_process_turn()