# --- Script del jugador ---
extends Node2D
class_name Player

# --- Constantes para la posición de las cartas ---
const CARD_WIDTH: float = 40.0
const SEPARATION_OFFSET: float = 20.0
const CENTER_POINT: float = 0.0
const TARGET_TIME: float = 0.2

# --- Mano actual del jugador ---
var current_hand: Array[Card] = []

# --- Propiedades del jugador ---
@export var is_turn: bool = false
@export var is_human: bool = false
@export var _auto_sort_cards: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# --- Función para añdadir una carta a la mano del jugador ---
func add_card_to_hand(new_card: Card) -> void:
	# Reparentar la carta al jugador
	new_card.reparent(self)

	# Añadir la carta a la mano actual
	current_hand.append(new_card)
	new_card.current_parent = self
	
	# Si el jugador es humano, reproducir la animación de voltear la carta
	if is_human:
		new_card.card_animator.play("flip_card")
	
	# Si es el turno del jugador, ordenar las cartas
	if _auto_sort_cards:
		_sort_cards()
	
	# Posicionar la carta en la mano del jugador
	_calculate_cards_position()
	await get_tree().create_timer(TARGET_TIME).timeout

# --- Función para calcular la posición de las cartas en la mano ---
func _calculate_cards_position() -> void:
	var hand_size: int = current_hand.size()
	var card_selected_index: int = -1

	for i: int in current_hand.size():
		var card: Card = current_hand[i]
		if card.is_selected:
			card_selected_index = i
			break
	
	for i: int in current_hand.size():
		# Obtener la carta actual
		var card: Card = current_hand[i]
		
		# Calcular la posición X basada en el índice de la carta
		var x_pos: float = CARD_WIDTH * (i - ((hand_size -1) / 2.0))
		var final_position: Vector2

		# Si hay una carta seleccionada, ajustar posiciones
		if card_selected_index != -1:
			if i < card_selected_index:
				# Mover a la izquierda
				x_pos = x_pos - SEPARATION_OFFSET
			elif i > card_selected_index:
				# Mover a la derecha
				x_pos = x_pos + SEPARATION_OFFSET

		# Definir la posición final de la carta
		final_position = Vector2(x_pos, CENTER_POINT)
		
		# Animar la carta a la posición calculada
		CardManager.move_card_to_position(card, final_position, TARGET_TIME, 0.0)

# --- Función para ordenar las cartas en la mano del jugador ---
func _sort_cards() -> void:
	# Diccionarios para asignar un peso numérico a cada tipo.
	var color_weights: Dictionary = {"red": 0, "green": 1, "yellow": 2, "blue": 3, "wild": 4}
	# sort_custom usa una función (lambda) para comparar dos elementos (a, b).
	# Debe devolver 'true' si 'a' va antes que 'b'.
	current_hand.sort_custom(
		func(a: Card, b: Card) -> bool:
			# 1. Comparar por color.
			var color_a_weight: int = color_weights.get(a.card_color, 99)
			var color_b_weight: int = color_weights.get(b.card_color, 99)

			# Si los colores son diferentes, compararlos por su peso.
			if color_a_weight < color_b_weight:
				return true
			if color_a_weight > color_b_weight:
				return false
			
			# 2. Si los colores son iguales, comparar por valor.
			var value_a_weight: int = a.card_symbol
			var value_b_weight: int = b.card_symbol

			# Si los valores son números, compararlos directamente.
			if value_a_weight < value_b_weight:
				return true
			if value_a_weight > value_b_weight:
				return false
			
			return value_a_weight < value_b_weight
			)
	
	# Obtenemos una referencia al nodo padre de las cartas
	var parent: Node2D = (current_hand[0] as Node2D).get_parent() as Player
	# Recorremos el array que AHORA está ordenado.
	for card: Card in current_hand:
		# move_child saca al nodo y lo vuelve a insertar en una nueva posición.
		# Usar el índice -1 significa "mover al final de la lista de hijos".
		parent.move_child(card, -1) 

# --- Función para colapsar la mano del jugador ---
func colapse_hand() -> void:
	# Mover todas las cartas a la posición (0, 0) relativa al jugador
	for card: Card in current_hand:
		CardManager.move_card_to_position(card, Vector2.ZERO, TARGET_TIME, 0.0)
	
	# Esperar a que termine la animación
	await get_tree().create_timer(TARGET_TIME).timeout

	# Después de colapsar, reordenar las cartas
	_sort_cards()
	_calculate_cards_position()