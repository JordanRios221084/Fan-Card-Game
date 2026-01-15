class_name GameManager
extends Node
## Controla la lógica principal del juego, incluyendo turnos, estados y gestión de jugadores.
##
## Contiene referencias a nodos clave como el mazo, el montón de descarte, el controlador de IA y los jugadores.
## También maneja la transición entre diferentes estados del juego y la aplicación de efectos de cartas.

# --- Signals ---
signal draw_card_finished ## Señal emitida cuando un jugador termina de robar cartas.
signal turn_changed ## Señal emitida cuando el turno del jugador actual ha terminado.

# --- Constants ---
const STARTING_CARDS: int = 7 ## Cantidad de cartas iniciales que recibe cada jugador.

# --- Enums ---
## Define los posibles estados del juego.
enum GameState {
	IDLE,
	GAME_STARTED,
	APPLY_EFFECTS,
	CHANGE_TURN,
	PLAYING_CARDS,
	GAME_ENDED
}

# --- Exports ---
@export_group("Table References")
@export var deck: Deck ## Referencia al mazo de cartas [Deck].
@export var discard_pile: DiscardPile ## Referencia al montón de descarte [DiscardPile].
@export var effect_manager: EffectManager ## Referencia al manejador de efectos [EffectManager].
@export var uno_button: UnoButton ## Referencia al botón "UNO" [Button].

@export_group("Player Management")
@export var players_container: PlayersContainer ## Contenedor de los jugadores [PlayersContainer].
@export var all_players: Array[Player] = [] ## Array que contiene referencias a todos los jugadores [Player].

@export_group("Game Parameters")
@export var steps: int = 1 ## Cantidad de pasos a mover en el turno (1 o más).
@export var direction: int = 1 ## Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
@export var current_state: GameState = GameState.IDLE ## Variable que almacena el estado actual del juego.
@export var draw_till_valid: bool = false ## Indica si el jugador debe robar hasta obtener una carta válida.

# --- Public Variables ---
var current_player: Player ## Referencia al jugador actual.
var next_player: Player ## Referencia al siguiente jugador.


# --- Engine Functions ---
func _ready() -> void:
	_set_database()
	get_players_references()
	set_controllers()
	start_game()










# -------------------- Inicio del Juego --------------------

## Configura el mazo de cartas con una copia de la base de datos.
func _set_database() -> void:
	# Asumimos que CardDatabase es un Autoload o clase estática
	deck.current_deck = CardDatabase.get_card_database()


## Obtiene referencias a todos los jugadores actuales y las almacena en [all_players].
func get_players_references() -> void:
	all_players.clear()
	all_players = players_container.get_current_players()


## Configura las señales y referencias de los controladores de IA y jugadores humanos.
func set_controllers() -> void:
	for player: Player in all_players:
		var controller: Controller = player.self_cotroller
		controller.game_manager = self

		controller.connect("check_card", _on_controller_check_card)
		controller.connect("play_card", _on_controller_play_card)
		controller.connect("draw_card", _on_controller_draw_card)
		controller.connect("two_cards_left", _on_controller_two_cards_left)


## Inicia el juego repartiendo cartas y configurando el estado inicial.
func start_game() -> void:
	const WAIT_TIME_SECONDS: float = 0.5
	await get_tree().create_timer(WAIT_TIME_SECONDS).timeout

	await deal_cards(WAIT_TIME_SECONDS)

	await get_tree().create_timer(WAIT_TIME_SECONDS).timeout

	var first_card: Card = deck.draw_card()
	CardManager.set_card_opacity(first_card, true)
	await discard_pile.receive_card(first_card, deck)
	#----------------------------------------------------------------------------

	effect_manager.start_arrows_indicator()

	# Marcar el juego como comenzado
	change_state(GameState.GAME_STARTED)


func deal_cards(wait_time: float) -> void:
	# Repartir 7 cartas a cada jugador
	for i: int in range(STARTING_CARDS):
		for player: Player in all_players:
			var card: Card = deck.draw_card()
			player.add_card_to_hand(card)
			await get_tree().create_timer(wait_time/4).timeout
	
	# Colapsar las cartas de cada jugador después de repartir
	await get_tree().create_timer(wait_time).timeout
	for player: Player in all_players:
		player.cards_container.collapse_cards()


## Determina y asigna el primer jugador.
func set_first_player() -> void:
	current_player = all_players.pick_random()

	# Calculamos el siguiente jugador
	var current_index: int = all_players.find(current_player)
	var next_index: int = (current_index + (steps * direction) + all_players.size()) % all_players.size()
	next_player = all_players[next_index]










# -------------------- Gestión de Turnos y Estados --------------------

## Cambia el turno al siguiente jugador según la dirección y los pasos definidos.
func change_current_player_turn() -> void:
	var total_players: int = all_players.size()
	var prev_current_player_index: int = all_players.find(current_player)
	var new_current_player_index: int = (prev_current_player_index + (steps * direction) + total_players) % total_players

	# Asignamos nuevo jugador actual
	current_player = all_players[new_current_player_index]

	# Reiniciamos pasos a 1
	steps = 1

	# Calculamos el "siguiente" jugador
	var next_player_index: int = (new_current_player_index + (steps * direction) + total_players) % total_players
	next_player = all_players[next_player_index]


## Máquina de estados principal.
## Cambia el estado actual y ejecuta la lógica de transición.
func change_state(new_state: GameState) -> void:
	current_state = new_state

	match current_state:
		GameState.GAME_STARTED:
			print("---------- JUEGO COMENZADO ----------")

			set_first_player()
			change_state(GameState.APPLY_EFFECTS)
			
		GameState.APPLY_EFFECTS:
			print("---------- APLICANDO EFECTOS ----------")
			var last_card: Card = discard_pile.top_card

			effect_manager.set_game_parameters(steps, direction)
			
			# Aplicar efecto si no ha sido usado aún
			if not discard_pile.check_top_card_effect_used():
				await effect_manager.process_effect(last_card, next_player)
			
			get_new_parameters() # Actualizamos parámetros del juego desde el EffectManager
			
			change_state(GameState.CHANGE_TURN)
			
		GameState.CHANGE_TURN:
			print("---------- CAMBIANDO TURNO ----------")

			change_current_player_turn()

			change_state(GameState.PLAYING_CARDS)
			
		GameState.PLAYING_CARDS:
			print("---------- JUGADOR JUGANDO ----------")
			var transition_time_seconds: float = 0.2

			set_cards_deck_state(true)

			# Procesar el turno del jugador actual
			current_player.process_turn()
			
			await turn_changed
			
			set_cards_deck_state(false)

			await get_tree().create_timer(transition_time_seconds).timeout
			change_state(GameState.APPLY_EFFECTS)
			
		GameState.GAME_ENDED:
			print("||| JUEGO TERMINADO |||")










# -------------------- Funciones de Juego --------------------

## Obtiene los parámetros actuales del juego desde el EffectManager.
func get_new_parameters() -> void:
	var updated_params: Dictionary = effect_manager.return_game_parameters()
	steps = updated_params.steps
	direction = updated_params.direction


## Verifica si una carta es válida para jugar según las reglas. [br]
## Reglas: Coincidir color, coincidir símbolo, o ser carta negra (Wild).
func is_valid_card(card_to_validate: Card) -> bool:
	var last_card: Card = discard_pile.top_card
	
	if card_to_validate.get_card_color() == "black":
		return true

	if card_to_validate.get_card_color() == last_card.get_card_color():
		return true

	if card_to_validate.get_card_symbol() == last_card.get_card_symbol():
		return true
	
	return false # Carta no válida


## Intenta jugar una carta para un jugador dado. [br]
## - [param target_card]: Carta que el jugador intenta jugar. [br]
## - [param target_player]: Jugador que intenta jugar la carta. [br]
func play_a_card(target_card: Card, target_player: Player) -> void:
	target_player.play_a_card(target_card)
	
	await discard_pile.receive_card(target_card, target_player)


## Maneja el proceso de robo de cartas para un jugador. [br]
## - [param target_player]: Jugador que robará las cartas. [br]
## - [param card_quantity]: Cantidad de cartas a robar. [br]
## - [param forced]: Indica si el robo es forzado (por efecto de carta). [br]
## - [param draw_speed]: Velocidad de robo (tiempo entre cartas
func draw_a_card(target_player: Player, card_quantity: int, forced: bool, draw_speed: float) -> void:
	deck.deck_collision_shape.disabled = true

	# Si es forzado, significa que se ha aplicado un efecto de robo múltiple forzado (+2, +4)
	if forced:
		for i: int in range(card_quantity):
			await get_new_card(target_player, draw_speed)
		return
	
	# Si debe robar hasta encontrar una válida
	if draw_till_valid:
		var stop_drawing: bool = false

		while not stop_drawing:
			var new_card: Card = await get_new_card(target_player, draw_speed)
			if is_valid_card(new_card):
				stop_drawing = true
	
	# Si no es hasta encontrar una válida, robamos una sola carta
	else:
		var new_card: Card = await get_new_card(target_player, draw_speed/2)
		if not is_valid_card(new_card):
			turn_changed.emit()
	
	# Emitimos la señal de robo finalizado
	draw_card_finished.emit()


## Obtiene una nueva carta del mazo y la añade a la mano del jugador objetivo. [br]
## - [param target_player]: Jugador que recibirá la carta. [br]
## - [param draw_time]: Tiempo de espera después de añadir la carta. [br]
## - [return]: La carta robada.
func get_new_card(target_player: Player, draw_time: float) -> Card:
	var new_card: Card = deck.draw_card()
	await target_player.add_card_to_hand(new_card)
	await get_tree().create_timer(draw_time).timeout
	return new_card


## Habilita o deshabilita la interacción visual de las cartas del jugador actual y el mazo.
func set_cards_deck_state(enabled: bool) -> void:
	# Deshabilitar interacción visual del jugador actual
	for card: Card in current_player.cards_container.current_hand:
		CardManager.set_card_opacity(card, enabled)
	
		if current_player.is_human:
			card.collision_shape.disabled = not enabled
			deck.deck_collision_shape.disabled = not enabled










# -------------------- Señales de los Controladores --------------------

## Escucha al montón de descarte cuando se ha descartado la primera carta.
func _on_discard_pile_first_card_discarded(card: Card) -> void:
	deck.recover_card(card)

## Escucha al effect manager cuando se ha procesado un efecto de robo de cartas.
func _on_effect_manager_draw_processed(target_player: Player, amount: int) -> void:
	var forced: bool = true
	var draw_speed: float = 0.05
	draw_a_card(target_player, amount, forced, draw_speed)


func _on_controller_check_card(card: Card) -> void:
	# Aquí podríamos manejar la verificación de la carta si es necesario
	pass


func _on_controller_play_card(card: Card, player: Player) -> void:
	pass


func _on_controller_draw_card(player: Player) -> void:
	pass


func _on_controller_two_cards_left(player: Player) -> void:
	pass