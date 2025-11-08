extends Node
class_name AIController

# --- Señales del controlador de la IA ---
signal check_card(card: Card)
signal play_card(card: Card, layer: Player)
signal draw_card(player: Player)

@export var game_manager: GameManager

var current_ai_player: Player
var valid_cards: Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# --- Función para intentar procesar el turno de la IA ---
func try_to_process_turn() -> void:
	# Si no hay un jugador...
	if not current_ai_player:
		return # Terminamos de ejecutar
	
	await _process_turn()

# --- Función para procesar el turno de la IA ---
func _process_turn() -> void:
	print("-- Jugador ia actual: ", current_ai_player, " --")
	print()
	# Generamos un tiempo aleatorio para simular pensamiento
	var random_wait_time: float = randf_range(0.5, 2)

	# Simulando que la IA está pensando
	await get_tree().create_timer(random_wait_time / 1.2).timeout

	# Verificar las cartas
	_check_current_cards(false)

	# Simulando que la IA está pensando
	await get_tree().create_timer(random_wait_time / 0.8).timeout

	# Si no tiene cartas válidas
	if valid_cards.is_empty():
		draw_card.emit(current_ai_player) # Emitimos la señal para pedir sacar una carta
		await _check_current_cards(true) # Esperamos a que termine de verificar las cartas
	
	# Si hay cartas válidas...
	if not valid_cards.is_empty():
		var ai_found_card: Card = valid_cards.pick_random() # Obtenemos una aleatoriamente
		play_card.emit(ai_found_card, current_ai_player) # Emitimos la señal para jugar la carta

	# Limpiamos las variables
	_clear_variables()

# --- Función para manejar la limpieza de variables
func _clear_variables() -> void:
	# Reiniciamos las variables para poder manejar nuevos datos
	current_ai_player = null
	valid_cards.clear()

# --- Función para verificar que cartas de la mano del jugador IA actual son válidas ---
func _check_current_cards(try_draw: bool) -> void:
	# Intentamos robar una carta
	if try_draw:
		await game_manager.draw_card_finished

	# Reiniciamos las cartas válidas
	valid_cards.clear()

	# Para cada carta en la mano del jugador IA actual...
	for card: Card in current_ai_player.current_hand:
		check_card.emit(card) # Emitimos una señal para verificar la carta
	
	# Esmerapos 0.5seg
	await get_tree().create_timer(0.5).timeout