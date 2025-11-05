extends Node
class_name AIController

signal check_card(target_card: Card)
signal play_card(found_card: Card, current_ai_player: Player)
signal draw_card

var ai_players: Array = []
var current_ai_player: Player

var valid_cards: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# --- Función para procesar el turno de la IA ---
func process_turn() -> void:
	# Buscar el jugador IA que tenga el turno
	for ai_player: Player in ai_players:
		if ai_player.is_turn:
			current_ai_player = ai_player # Una vez encontrado, rompemos el bucle
			break
	
	# Si no encontó ninguno, terminamos de ejecutar
	if not current_ai_player:
		return
	
	# Generamos un tiempo aleatorio para simular pensamiento
	var random_wait_time: float = randf_range(0.5, 2)

	# Simulando que la IA está pensando
	await get_tree().create_timer(random_wait_time - 0.3).timeout

	# Verificamos que cartas de la mano del jugador IA actual son válidas
	for card: Card in current_ai_player.current_hand:
		check_card.emit(card)

	# Simulando que la IA está pensando
	await get_tree().create_timer(random_wait_time * 0.1).timeout

	# Si no tiene cartas válidas, terminamos de ejecutar por el momento <-------
	if valid_cards.is_empty():
		return
	
	# Buscar la carta a jugar dentro de las cartas válidas
	var ai_found_card: Card = valid_cards.pick_random()

	# Jugar la carta IA encontrada
	play_card.emit(ai_found_card)