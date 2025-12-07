class_name Player
extends Node2D
## Jugador que contiene la lógica para manejar su mano de cartas.
##
## Contiene funciones para añadir cartas, ordenar la mano y calcular posiciones.

# --- Private Constants ---
## Define el ancho de cada carta en la mano.
const _CARD_WIDTH: float = 40.0 
## Define la rotación estándar de las cartas en la mano.
const _CARD_ROTATION: float = 0.0 
## Define el desplazamiento al separar cartas.
const _SEPARATION_OFFSET: float = 20.0 
## Define el tamaño máximo de la mano.
const _MAX_HAND_SIZE: int = 10 
## Define el punto central para posicionar cartas.
const _CENTER_POINT: float = 0.0 
## Tiempo estándar para mover cartas.
const _MOVE_TIME_SECONDS: float = 0.4 
## Tiempo objetivo para sincronizar estados.
const _WAIT_TIME_SECONDS: float = 0.25 
## Pesos de los colores para el ordenamiento.
const _COLOR_WEIGHTS: Dictionary = {
	"red": 0, 
	"green": 1, 
	"yellow": 2, 
	"blue": 3, 
	"wild": 4
}

# --- Exports ---
@export_group("Status")
## Indica si es el turno del jugador.
@export var is_turn: bool = false
## Indica si el jugador es humano.
@export var is_human: bool = true

@export_group("Settings")
## Indica si las cartas se ordenan automáticamente.
@export var _auto_sort_cards: bool = false

# --- Public Variables ---
## Arreglo que contiene las cartas en la mano del jugador.
var current_hand: Array[Card] = []

# --- Engine Functions ---
func _ready() -> void:
	pass


# --- Public Functions ---
## Añade una carta a la mano del jugador y actualiza su posición. [br]
## Si el jugador es humano, reproduce una animación de voltear la carta. [br]
## Si es el turno del jugador, ordena las cartas automáticamente.
func add_card_to_hand(new_card: Card) -> void:
	new_card.reparent(self)

	current_hand.append(new_card)
	new_card.current_parent = self
	
	if is_human:
		new_card.card_animator.play("flip_card")
	
	if _auto_sort_cards:
		_sort_cards()
	
	_calculate_cards_position()
	
	print("Tiempo opcional de espera: ", _WAIT_TIME_SECONDS)
	await get_tree().create_timer(_WAIT_TIME_SECONDS).timeout


## Elimina una carta de la mano del jugador y actualiza la posición de las cartas restantes.
func play_a_card(card_to_play: Card) -> void:
	current_hand.erase(card_to_play)
	_calculate_cards_position()


## Colapsa todas las cartas de la mano del jugador a la posición (0, 0) relativa al jugador.
## Después de colapsar, reordena las cartas, recalcula sus posiciones y activa el auto-ordenamiento.
## Este método es asíncrono y espera a que termine la animación antes de continuar.
func collapse_hand() -> void:
	for card: Card in current_hand:
		CardManager.move_card_to_position(card, Vector2.ZERO, _MOVE_TIME_SECONDS/2, _CARD_ROTATION)
	
	await get_tree().create_timer(_WAIT_TIME_SECONDS).timeout

	_sort_cards()
	_calculate_cards_position()
	_auto_sort_cards = true # Activar el auto-ordenamiento


# --- Private Functions ---
## Calcula y actualiza las posiciones de las cartas en la mano del jugador.
func _calculate_cards_position() -> void:
	var hand_size: int = current_hand.size()
	if hand_size == 0:
		return

	var card_selected_index: int = -1
	var variable_width: float = 1.0

	for card_index: int in hand_size:
		var card: Card = current_hand[card_index]
		if card.is_selected:
			card_selected_index = card_index
			break
	
	if hand_size > _MAX_HAND_SIZE:
		variable_width = ((_CARD_WIDTH / hand_size) * 10) / _CARD_WIDTH
	
	for card_index: int in hand_size:
		var card: Card = current_hand[card_index]
		
		# Calcula la posición X basada en el índice de la carta y el ancho variable
		var x_pos: float = (_CARD_WIDTH * variable_width) * (card_index - ((hand_size - 1) / 2.0))
		
		if card_selected_index != -1:
			if card_index < card_selected_index:
				x_pos -= _SEPARATION_OFFSET
			elif card_index > card_selected_index:
				x_pos += _SEPARATION_OFFSET

		var final_position: Vector2 = Vector2(x_pos, _CENTER_POINT)
		CardManager.move_card_to_position(card, final_position, _MOVE_TIME_SECONDS, _CARD_ROTATION)

## Ordena las cartas en la mano del jugador por color y valor.
## Las cartas se ordenan primero por color (rojo, verde, amarillo, azul, comodín) y luego por valor numérico.
func _sort_cards() -> void:
	if current_hand.is_empty():
		return

	# sort_custom usa una función lambda para comparar dos elementos (a, b).
	current_hand.sort_custom(
		func(card_a: Card, card_b: Card) -> bool:
			# Comparar por color usando el diccionario constante
			var color_a_weight: int = _COLOR_WEIGHTS.get(card_a.card_color, 99)
			var color_b_weight: int = _COLOR_WEIGHTS.get(card_b.card_color, 99)

			if color_a_weight != color_b_weight:
				return color_a_weight < color_b_weight
			
			# Si los colores son iguales, comparar por valor (symbol)
			return card_a.card_symbol < card_b.card_symbol
	)
	
	# Reordenar los nodos en el árbol de escena para que coincidan con el arreglo ordenado
	for card: Card in current_hand:
		move_child(card, -1)