class_name AutoController
extends Controller
## Contiene la lógica para controlar el comportamiento de los jugadores IA durante el juego.
##
## Gestiona el turno de los jugadores IA, incluyendo la selección y juego de cartas válidas
## o la acción de robar cartas cuando no hay opciones disponibles.


# --- Constants ---
const WAIT_TIME_SECONDS: Vector2 = Vector2(0.5, 1.0) ## Tiempo de espera estándar para simular el pensamiento de la IA.
const MULTIPLIER_TIME: float = 1.5 ## Multiplicador para ajustar tiempos de espera.
const DIVIDER_TIME: float = 0.5 ## Divisor para ajustar tiempos de espera.

# --- Variables ---
## Lista de cartas válidas que el jugador IA puede jugar.
## Se asume que esta lista se llena externamente al emitir [signal AIController.check_card].
var valid_cards: Array[Card] = []


# --- Public Functions ---
## Añade una carta válida a la lista de cartas válidas. [br]
## - [param card] La carta que se considera válida para jugar.
func add_valid_card(card: Card) -> void:
	valid_cards.append(card)


# --- Private Functions ---
func try_to_process_turn() -> void:
	if player.cards_container.current_hand.size() == 2:
		notify_two_cards_left() # Emite una señal si el jugador tiene 2 cartas
	
	var random_wait_time: float = randf_range(WAIT_TIME_SECONDS.x, WAIT_TIME_SECONDS.y)
	random_wait_time = 0.1

	await get_tree().create_timer(random_wait_time * MULTIPLIER_TIME).timeout

	await check_current_cards()

	await get_tree().create_timer(random_wait_time / DIVIDER_TIME).timeout
	
	if valid_cards.is_empty():
		draw_a_card()
		await game_manager.draw_card_finished
		await check_current_cards()
	
	if valid_cards.size() > 0:
		var ai_found_card: Card = valid_cards.pick_random()
		play_a_card(ai_found_card)

	clear_variables()


## Verifica las cartas actuales del jugador IA para determinar cuáles son válidas para jugar. [br]
## Emite la señal [signal AIController.check_card] para cada carta en la mano del jugador IA.
func check_current_cards() -> void:
	valid_cards.clear()

	for card: Card in player.cards_container.current_hand:
		check_a_card(card)

	await get_tree().create_timer(0.1).timeout


## Limpia las variables del controlador de la IA.
## Reinicia el jugador actual y la lista de cartas para el siguiente turno.
func clear_variables() -> void:
	valid_cards.clear()