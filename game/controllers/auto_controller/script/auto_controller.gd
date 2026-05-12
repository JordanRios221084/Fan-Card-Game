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


# -------------------- Procesamiento automatico de la IA --------------------

func try_to_process_turn() -> void:
	if player.cards_container.current_hand.size() == 2:
		notify_two_cards_left() # Emite una señal si el jugador tiene 2 cartas
	
	var random_wait_time: float = randf_range(WAIT_TIME_SECONDS.x, WAIT_TIME_SECONDS.y)
	random_wait_time = 0.1 # Ajuste temporal para pruebas rápidas

	await get_tree().create_timer(random_wait_time * MULTIPLIER_TIME).timeout
	check_current_cards()
	await get_tree().create_timer(random_wait_time / DIVIDER_TIME).timeout
	
	if valid_cards.is_empty():
		await card_draw()
		check_current_cards()
	
	if not valid_cards.is_empty():
		var found_card: Card = valid_cards.pick_random()
		card_play(found_card)

	clear_variables()

func try_to_select_color() -> void:
	var cards: Dictionary = count_cards()
	
	var most_repeated_color: String
	var max_value: float = - INF
	
	for color: String in cards:
		if cards[color] > max_value:
			max_value = cards[color]
			most_repeated_color = color
	
	var random_wait_time: float = randf_range(WAIT_TIME_SECONDS.x, WAIT_TIME_SECONDS.y)
	random_wait_time = 0.1 # Ajuste temporal para pruebas rápidas

	await get_tree().create_timer(random_wait_time * MULTIPLIER_TIME).timeout
	
	color_select(most_repeated_color)

func count_cards() -> Dictionary:
	var all_cards: Dictionary = {
		"red" : 0,
		"blue" : 0,
		"yellow" : 0,
		"green" : 0
	}
	
	for card: Card in player.cards_container.current_hand:
		match  card.get_card_color():
			"red":
				all_cards.red += 1
			"blue":
				all_cards.blue += 1
			"yellow":
				all_cards.yellow += 1
			"green":
				all_cards.green += 1
			_:
				print("Wild card detectado, no se añade")
	
	return all_cards



## Verifica las cartas actuales del jugador para determinar cuáles son válidas para jugar. [br]
## Emite la señal [signal AutoController.card_check] para cada carta en la mano del jugador.
func check_current_cards() -> void:
	clear_variables()

	# Emitir señal para verificar cada carta en la mano del jugador
	for card: Card in player.cards_container.current_hand:
		card_check(card)


## Limpia las variables del controlador de la IA.
## Reinicia el jugador actual y la lista de cartas para el siguiente turno.
func clear_variables() -> void:
	valid_cards.clear()
