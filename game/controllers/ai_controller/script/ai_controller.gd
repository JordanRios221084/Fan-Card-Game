class_name AIController
extends Controller
## Contiene la lógica para controlar el comportamiento de los jugadores IA durante el juego.
##
## Gestiona el turno de los jugadores IA, incluyendo la selección y juego de cartas válidas
## o la acción de robar cartas cuando no hay opciones disponibles.


# --- Private Constants ---
## Tiempo de espera estándar para simular el pensamiento de la IA.
## Se usa un rango para variar el tiempo y hacerlo menos predecible.
const _WAIT_TIME_SECONDS: Vector2 = Vector2(0.5, 1.0)
## Multiplicador para ajustar tiempos de espera.
const _MULTIPLIER_TIME: float = 1.5
## Divisor para ajustar tiempos de espera.
const _DIVIDER_TIME: float = 0.5

# --- Private Variables ---
## Lista de cartas válidas que el jugador IA puede jugar.
## Se asume que esta lista se llena externamente al emitir [signal AIController.check_card].
var _valid_cards: Array[Card] = []


# --- Public Functions ---
## Añade una carta válida a la lista de cartas válidas. [br]
## - [param card] La carta que se considera válida para jugar.
func add_valid_card(card: Card) -> void:
	_valid_cards.append(card)


# --- Private Functions ---
func _process_turn() -> void:
	if _player.cards_container.current_hand.size() == 2:
		two_cards_left.emit(_player) # Emite una señal si el jugador tiene 2 cartas
	
	var random_wait_time: float = randf_range(_WAIT_TIME_SECONDS.x, _WAIT_TIME_SECONDS.y)
	random_wait_time = 0.1

	print("Tiempo N°1 de espera: ", random_wait_time * _MULTIPLIER_TIME)
	await get_tree().create_timer(random_wait_time * _MULTIPLIER_TIME).timeout

	await _check_current_cards()

	print("Tiempo N°3 de espera: ", random_wait_time / _DIVIDER_TIME)
	await get_tree().create_timer(random_wait_time / _DIVIDER_TIME).timeout
	
	if _valid_cards.is_empty():
		draw_card.emit(_player)
		await  game_manager.draw_card_finished
		await _check_current_cards()
	
	if _valid_cards.size() > 0:
		var ai_found_card: Card = _valid_cards.pick_random()
		play_card.emit(ai_found_card, _player)

	_clear_variables()


func _check_current_cards() -> void:
	_valid_cards.clear()

	for card: Card in _player.cards_container.current_hand:
		check_card.emit(card)
	
	print("Tiempo N°2 de espera: ", _WAIT_TIME_SECONDS.x)
	await get_tree().create_timer(0.1).timeout


## Limpia las variables del controlador de la IA.
## Reinicia el jugador actual y la lista de cartas para el siguiente turno.
func _clear_variables() -> void:
	_valid_cards.clear()