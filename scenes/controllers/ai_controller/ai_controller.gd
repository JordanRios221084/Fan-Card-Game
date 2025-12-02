extends Node
class_name AIController
## [b]Descripción:[/b] Controlador de la IA que maneja el comportamiento de los jugadores controlados por la IA. [br]
## Contiene señales y funciones para procesar los turnos de la IA y verificar las cartas válidas.

signal check_card(card: Card) ## Clase: [AIController] [br] Verifica si una carta IA es válida para jugar.
signal play_card(card: Card, layer: Player) ## Clase: [AIController] [br] Juega una carta por parte del jugador IA.
signal draw_card(player: Player) ## Clase: [AIController] [br] Solicita que el jugador IA robe una carta.

@export var game_manager: GameManager ## Referencia al GameManager para manejar el estado del juego.

var current_ai_player: Player ### Referencia al jugador IA actual cuyo turno se está procesando.
var valid_cards: Array[Card] = [] ## Lista de cartas válidas que el jugador IA puede jugar.
var random_wait_time_seconds: float ## Tiempo de espera aleatorio para simular el pensamiento de la IA en segundos.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Pertenece a: [AIController] [br]
## [b]Descripción:[/b] Intenta procesar el turno del jugador IA actual. [br]
## Si no hay un jugador IA actual, la función termina sin hacer nada.
func try_to_process_turn() -> void:
	# Si no hay un jugador...
	if not current_ai_player:
		return # Terminamos de ejecutar
	
	await _process_turn()

## [Método privado] [br]
## [b]Descripción:[/b] Procesa el turno del jugador IA actual. [br]
## La función simula el pensamiento de la IA, verifica las cartas válidas y decide si
## jugar una carta o robar una nueva. [br]
## Si la carta robada es válida, la juega; de lo contrario, termina su turno.
func _process_turn() -> void:
	print("-- Jugador ia actual: ", current_ai_player, " --")
	print()

	random_wait_time_seconds = randf_range(0.5, 1) # Tiempo de espera aleatorio entre 0.5 y 1 segundos

	await get_tree().create_timer(random_wait_time_seconds * 1.2).timeout # Multiplicador para variar el tiempo de espera

	_check_current_cards(false)

	await get_tree().create_timer(random_wait_time_seconds / 0.8).timeout # Divisor para variar el tiempo de espera
	if valid_cards.is_empty():
		draw_card.emit(current_ai_player)
		await _check_current_cards(true)
	
	if not valid_cards.is_empty():
		var ai_found_card: Card = valid_cards.pick_random()
		play_card.emit(ai_found_card, current_ai_player)

	_clear_variables()

## [Método privado] [br]
## [b]Descripción:[/b] Limpia las variables del controlador de la IA. [br]
## Reinicia el jugador IA actual y la lista de cartas válidas para preparar el siguiente turno
func _clear_variables() -> void:
	current_ai_player = null
	valid_cards.clear()

## [Método privado] [br]
## [b]Descripción:[/b] Verifica las cartas actuales en la mano del jugador IA. [br]
## Si `try_draw` es verdadero, espera a que el jugador termine de robar una carta antes de verificar.
## Emite una señal para cada carta en la mano del jugador IA para comprobar si es válida.
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