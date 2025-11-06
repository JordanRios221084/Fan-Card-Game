extends Node
class_name AIController

# --- Señales del controlador de la IA ---
signal check_card(target_card: Card)
signal play_card(found_card: Card, current_ai_player: Player)
signal draw_card

var current_ai_player: Player
var valid_cards: Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func try_to_process_turn() -> void:
	# Si no hay un jugador, terminamos de ejecutar
	if not current_ai_player:
		return
	
	_process_turn()

# --- Función para procesar el turno de la IA ---
func _process_turn() -> void:
	print("Jugador ia actual: ", current_ai_player)
	# Generamos un tiempo aleatorio para simular pensamiento
	var random_wait_time: float = randf_range(0.5, 2)

	# Simulando que la IA está pensando
	await get_tree().create_timer(random_wait_time / 1.2).timeout

	# Verificamos que cartas de la mano del jugador IA actual son válidas
	for card: Card in current_ai_player.current_hand:
		check_card.emit(card)

	# Simulando que la IA está pensando
	await get_tree().create_timer(random_wait_time / 0.8).timeout

	# Si no tiene cartas válidas, terminamos de ejecutar por el momento <-------
	if valid_cards.is_empty():
		draw_card.emit()
		return
	
	# Buscar la carta a jugar dentro de las cartas válidas
	var ai_found_card: Card = valid_cards.pick_random()

	# Jugar la carta IA encontrada
	play_card.emit(ai_found_card, current_ai_player)

	# Limpiamos las variables
	_clear_variables()

# --- Función para manejar la limpieza de variables
func _clear_variables() -> void:
	# Reiniciamos las variables para poder manejar nuevos datos
	current_ai_player = null
	valid_cards = []