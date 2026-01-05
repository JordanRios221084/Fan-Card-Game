class_name CardsContainer
extends Node2D
## Contenedor de cartas para el jugador


# --- Signals ---
signal card_selected(card: Card)
signal card_deselected(card: Card)


# --- Constants ---
const CARD_WIDTH: float = 40.0 ## Define el ancho de cada carta en la mano.
const CARD_ROTATION: float = 0.0 ## Define la rotación estándar de las cartas en la mano.
const SEPARATION_OFFSET: float = 20.0 ## Define el desplazamiento al separar cartas.
const MAX_HAND_SIZE: int = 10 ## Define el tamaño máximo de la mano.
const CENTER_POINT: float = 0.0 ## Define el punto central para posicionar cartas.
const MOVE_TIME_SECONDS: float = 0.4 ## Tiempo estándar para mover cartas.
const WAIT_TIME_SECONDS: float = 0.25 ## Tiempo objetivo para sincronizar estados.

## Pesos de los colores para el ordenamiento.
const COLOR_WEIGHTS: Dictionary = {
	"red": 0, 
	"green": 1, 
	"yellow": 2, 
	"blue": 3, 
	"wild": 4
}

# --- Exports ---
@export_group("Settings")
## Indica si las cartas se ordenan automáticamente.
@export var auto_sort_cards: bool = false

# --- Public Variables ---
## Arreglo que contiene las cartas en la mano del jugador.
var current_hand: Array[Card] = []


# --- Public Functions ---
## Colapsa todas las cartas de la mano del jugador a la posición (0, 0) relativa al jugador.
## Después de colapsar, reordena las cartas, recalcula sus posiciones y activa el auto-ordenamiento.
## Este método es asíncrono y espera a que termine la animación antes de continuar.
func collapse_cards() -> void:
	for card: Card in current_hand:
		CardManager.move_card_to_position(card, Vector2.ZERO, MOVE_TIME_SECONDS/2, CARD_ROTATION)
	
	await get_tree().create_timer(WAIT_TIME_SECONDS).timeout

	sort_cards()
	allign_cards()
	auto_sort_cards = true # Activar el auto-ordenamiento


## Calcula y actualiza las posiciones de las cartas en la mano dada del jugador.
func allign_cards() -> void:
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
	
	if hand_size > MAX_HAND_SIZE:
		variable_width = ((CARD_WIDTH / hand_size) * 10) / CARD_WIDTH
	
	for card_index: int in hand_size:
		var card: Card = current_hand[card_index]
		
		# Calcula la posición X basada en el índice de la carta y el ancho variable
		var x_pos: float = (CARD_WIDTH * variable_width) * (card_index - ((hand_size - 1) / 2.0))
		var y_pos: float = 0.0
		
		if card_selected_index != -1:
			if card_index < card_selected_index:
				x_pos -= SEPARATION_OFFSET
			
			elif card_index > card_selected_index:
				if hand_size > MAX_HAND_SIZE +5:
					x_pos += SEPARATION_OFFSET + hand_size
				else:
					x_pos += SEPARATION_OFFSET
			
			elif card_index == card_selected_index:
				y_pos = -15.0
		
		var final_position: Vector2 = Vector2(x_pos, CENTER_POINT + y_pos)
		CardManager.move_card_to_position(card, final_position, MOVE_TIME_SECONDS, CARD_ROTATION)


## Ordena las cartas en la mano del jugador por color y valor.
## Las cartas se ordenan primero por color (rojo, verde, amarillo, azul, comodín) y luego por valor numérico.
func sort_cards() -> void:
	if current_hand.is_empty():
		return

	# sort_custom usa una función lambda para comparar dos elementos (a, b).
	current_hand.sort_custom(
		func(card_a: Card, card_b: Card) -> bool:
			# Comparar por color usando el diccionario constante
			var color_a_weight: int = COLOR_WEIGHTS.get(card_a.values.color, 99)
			var color_b_weight: int = COLOR_WEIGHTS.get(card_b.values.color, 99)

			if color_a_weight != color_b_weight:
				return color_a_weight < color_b_weight
			
			# Si los colores son iguales, comparar por valor (symbol)
			return card_a.values.symbol < card_b.values.symbol
	)
	
	# Reordenar los nodos en el árbol de escena para que coincidan con el arreglo ordenado
	for card: Card in current_hand:
		move_child(card, -1)


func insert_card_to_hand(new_card: Card) -> void:
	new_card.reparent(self)
	current_hand.append(new_card)
	new_card.current_parent = self

	if auto_sort_cards:
		sort_cards()

	new_card.mouse_on_card.connect(_on_card_mouse_entered_card)
	new_card.mouse_off_card.connect(_on_card_mouse_exited_card)


# --- Private Functions ---
func _on_card_mouse_entered_card(card: Card) -> void:
	card_selected.emit(card)


func _on_card_mouse_exited_card(card: Card) -> void:
	card_deselected.emit(card)