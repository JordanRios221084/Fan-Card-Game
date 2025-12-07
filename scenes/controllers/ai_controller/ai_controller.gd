class_name AIController
extends Node
## Contiene la lógica para controlar el comportamiento de los jugadores IA durante el juego.
##
## Gestiona el turno de los jugadores IA, incluyendo la selección y juego de cartas válidas
## o la acción de robar cartas cuando no hay opciones disponibles.

# --- Signals ---
## Verifica si una carta IA es válida para jugar.
signal check_card(card: Card)
## Juega una carta por parte del jugador IA.
signal play_card(card: Card, player: Player)
## Solicita que el jugador IA robe una carta.
signal draw_card(player: Player)

# --- Private Constants ---
## Tiempo de espera estándar para simular el pensamiento de la IA.
## Se usa un rango para variar el tiempo y hacerlo menos predecible.
const _WAIT_TIME_SECONDS: Vector2 = Vector2(0.5, 1.0)
## Multiplicador para ajustar tiempos de espera.
const _MULTIPLIER_TIME: float = 1.5
## Divisor para ajustar tiempos de espera.
const _DIVIDER_TIME: float = 0.5

# --- Exports ---
@export_group("References")
## Referencia al [GameManager] para manejar el estado del juego.
@export var game_manager: GameManager

# --- Public Variables ---
## Referencia al jugador IA actual cuyo turno se está procesando.
## Se debe asignar antes de llamar a try_to_process_turn().
var current_ai_player: Player

## Lista de cartas válidas que el jugador IA puede jugar.
## Se asume que esta lista se llena externamente al emitir [signal AIController.check_card].
var _valid_cards: Array[Card] = []

# --- Engine Functions ---
func _ready() -> void:
	pass


# --- Public Functions ---
## Intenta procesar el turno del jugador IA actual.
## Si no hay un jugador IA actual, la función termina sin hacer nada.
func try_to_process_turn() -> void:
	# Si no hay un jugador asignado, terminamos.
	if not current_ai_player:
		return
	
	await _process_turn()


## Añade una carta válida a la lista de cartas válidas. [br]
## - [param card] La carta que se considera válida para jugar.
func add_valid_card(card: Card) -> void:
	_valid_cards.append(card)


# --- Private Functions ---
## Procesa el turno del jugador IA actual.
## Simula el pensamiento de la IA, verifica las cartas válidas y decide si jugar o robar.
func _process_turn() -> void:
	print("-- Jugador IA actual: ", current_ai_player, " --")
	print()
	
	var random_wait_time: float = randf_range(_WAIT_TIME_SECONDS.x, _WAIT_TIME_SECONDS.y)

	print("Tiempo N°1 de espera: ", random_wait_time * _MULTIPLIER_TIME)
	await get_tree().create_timer(random_wait_time * _MULTIPLIER_TIME).timeout

	await _check_current_cards(false)

	print("Tiempo N°3 de espera: ", random_wait_time / _DIVIDER_TIME)
	await get_tree().create_timer(random_wait_time / _DIVIDER_TIME).timeout
	
	if _valid_cards.is_empty():
		draw_card.emit(current_ai_player)
		await _check_current_cards(true)
	
	if _valid_cards.size() > 0:
		var ai_found_card: Card = _valid_cards.pick_random()
		play_card.emit(ai_found_card, current_ai_player)

	_clear_variables()


## Verifica las cartas actuales en la mano del jugador IA. [br]
## Si [param try_draw] es verdadero, espera a que el jugador termine de robar antes de verificar.
func _check_current_cards(alredy_drawning: bool) -> void:
	if alredy_drawning:
		print("Esperando a que el jugador IA termine de robar...")
		await game_manager.draw_card_finished

	_valid_cards.clear()

	for card: Card in current_ai_player.current_hand:
		check_card.emit(card)
	
	print("Tiempo N°2 de espera: ", _WAIT_TIME_SECONDS.x)
	await get_tree().create_timer(_WAIT_TIME_SECONDS.x).timeout


## Limpia las variables del controlador de la IA.
## Reinicia el jugador actual y la lista de cartas para el siguiente turno.
func _clear_variables() -> void:
	current_ai_player = null
	_valid_cards.clear()