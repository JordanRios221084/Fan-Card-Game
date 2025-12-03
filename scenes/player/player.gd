class_name Player
extends Node2D

## Jugador que contiene la lógica para manejar su mano de cartas.
##
## Contiene funciones para añadir cartas, ordenar la mano y calcular posiciones.

# --- Constants ---

const CARD_WIDTH: float = 40.0 ## Define el ancho de cada carta en la mano.
const SEPARATION_OFFSET: float = 20.0 ## Define el desplazamiento al separar cartas.
const MAX_HAND_SIZE: int = 10 ## Define el tamaño máximo de la mano.
const CENTER_POINT: float = 0.0 ## Define el punto central para posicionar cartas.
const TARGET_TIME: float = 0.2 ## Define el tiempo objetivo para animaciones.

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
@export var is_human: bool = false

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

## Añade una carta a la mano del jugador y actualiza su posición.
## Si el jugador es humano, reproduce una animación de voltear la carta.
## Si es el turno del jugador, ordena las cartas automáticamente.
func add_card_to_hand(new_card: Card) -> void:
	# Reparentar la carta al jugador
	new_card.reparent(self)

	# Añadir la carta a la mano actual y asignar referencia
	current_hand.append(new_card)
	new_card.current_parent = self
	
	# Si el jugador es humano, reproducir la animación de voltear la carta
	if is_human:
		new_card.card_animator.play("flip_card")
	
	# Si es el turno del jugador y está activado, ordenar las cartas
	if _auto_sort_cards:
		_sort_cards()
	
	# Posicionar la carta en la mano del jugador
	_calculate_cards_position()
	
	# Pequeña espera para sincronizar animaciones
	await get_tree().create_timer(TARGET_TIME).timeout


## Elimina una carta de la mano del jugador y actualiza la posición de las cartas restantes.
func play_a_card(card_to_play: Card) -> void:
	current_hand.erase(card_to_play)
	_calculate_cards_position()


## Colapsa todas las cartas de la mano del jugador a la posición (0, 0) relativa al jugador.
## Después de colapsar, reordena las cartas, recalcula sus posiciones y activa el auto-ordenamiento.
## Este método es asíncrono y espera a que termine la animación antes de continuar.
func collapse_hand() -> void:
	# Mover todas las cartas a la posición (0, 0) relativa al jugador
	for card: Card in current_hand:
		# Asumimos que CardManager es un Autoload disponible
		CardManager.move_card_to_position(card, Vector2.ZERO, TARGET_TIME, 0.0)
	
	# Esperar a que termine la animación
	await get_tree().create_timer(TARGET_TIME).timeout

	# Después de colapsar...
	_sort_cards() # Reordenar las cartas
	_calculate_cards_position() # Recalcular sus posiciones
	_auto_sort_cards = true # Reactivar el auto-ordenamiento

# --- Private Functions ---

## Calcula y actualiza las posiciones de las cartas en la mano del jugador.
func _calculate_cards_position() -> void:
	var hand_size: int = current_hand.size()
	if hand_size == 0:
		return

	var card_selected_index: int = -1
	var variable_width: float = 1.0

	# Buscar si hay alguna carta seleccionada
	for i: int in hand_size:
		var card: Card = current_hand[i]
		if card.is_selected:
			card_selected_index = i
			break
	
	# Calcular factor de compresión si la mano excede el tamaño máximo visual
	if hand_size > MAX_HAND_SIZE:
		variable_width = ((CARD_WIDTH / hand_size) * 10) / CARD_WIDTH
	
	for i: int in hand_size:
		# Obtener la carta actual
		var card: Card = current_hand[i]
		
		# Calcular la posición X basada en el índice de la carta y el ancho variable
		var x_pos: float = (CARD_WIDTH * variable_width) * (i - ((hand_size - 1) / 2.0))
		
		# Si hay una carta seleccionada, abrir espacio (offset)
		if card_selected_index != -1:
			if i < card_selected_index:
				x_pos -= SEPARATION_OFFSET
			elif i > card_selected_index:
				x_pos += SEPARATION_OFFSET

		# Definir la posición final de la carta
		var final_position: Vector2 = Vector2(x_pos, CENTER_POINT)
		
		# Animar la carta a la posición calculada
		CardManager.move_card_to_position(card, final_position, TARGET_TIME, 0.0)


## Ordena las cartas en la mano del jugador por color y valor.
## Las cartas se ordenan primero por color (rojo, verde, amarillo, azul, comodín) y luego por valor numérico.
func _sort_cards() -> void:
	if current_hand.is_empty():
		return

	# sort_custom usa una función lambda para comparar dos elementos (a, b).
	current_hand.sort_custom(
		func(a: Card, b: Card) -> bool:
			# 1. Comparar por color usando el diccionario constante
			var color_a_weight: int = _COLOR_WEIGHTS.get(a.card_color, 99)
			var color_b_weight: int = _COLOR_WEIGHTS.get(b.card_color, 99)

			if color_a_weight != color_b_weight:
				return color_a_weight < color_b_weight
			
			# 2. Si los colores son iguales, comparar por valor (symbol)
			return a.card_symbol < b.card_symbol
	)
	
	# Reordenar los nodos en el árbol de escena para que coincidan con el array
	# 'self' es el padre de las cartas, no necesitamos buscarlo
	for card: Card in current_hand:
		move_child(card, -1)