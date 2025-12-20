class_name GameManager
extends Node
## Controla la lógica principal del juego, incluyendo turnos, estados y gestión de jugadores.
##
## Contiene referencias a nodos clave como el mazo, el montón de descarte, el controlador de IA y los jugadores.
## También maneja la transición entre diferentes estados del juego y la aplicación de efectos de cartas.

# --- Signals ---
## Señal emitida cuando un jugador termina de robar cartas.
signal draw_card_finished

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

@export_group("Player Management")
@export var players_container: PlayersContainer ## Contenedor de los jugadores [PlayersContainer].
@export var all_players: Array[Player] = [] ## Array que contiene referencias a todos los jugadores [Player].
@export var ai_controller: AIController ## Referencia al controlador de IA [AIController].
@export var player_controller: PlayerController ## Referencia al controlador de jugadores humanos [PlayerController].

@export_group("Classes References")
@export var effect_manager: EffectManager ## Referencia al manejador de efectos [EffectManager].

# --- Public Variables ---
var prev_winner: Player ## Referencia al jugador que ganó la partida anterior.
var current_player: Player ## Referencia al jugador actual.
var next_player: Player ## Referencia al siguiente jugador.

var steps: int = 1 ## Cantidad de pasos a mover en el turno (1 o más).
var direction: int = 1 ## Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
var current_state: GameState = GameState.IDLE ## Variable que almacena el estado actual del juego.


# --- Engine Functions ---
func _ready() -> void:
	_set_database()

	_get_players_references()

	_set_controllers()

	_start_effect_manager()

	_start_game()


# --- Private Functions ---
## Configura el mazo de cartas con una copia de la base de datos.
func _set_database() -> void:
	# Asumimos que CardDatabase es un Autoload o clase estática
	deck.current_deck = CardDatabase.get_card_database()


## Obtiene referencias a todos los jugadores actuales y las almacena en [all_players].
func _get_players_references() -> void:
	all_players.clear()
	all_players = players_container.get_current_players()


## Configura las señales y referencias de los controladores de IA y jugadores humanos.
func _set_controllers() -> void:
	ai_controller.game_manager = self
	player_controller.game_manager = self

	ai_controller.connect("check_card", _on_controller_check_card)
	ai_controller.connect("play_card", _on_controller_play_card)
	ai_controller.connect("draw_card", _on_controller_draw_card)

	player_controller.connect("check_card", _on_controller_check_card)
	player_controller.connect("play_card", _on_controller_play_card)
	player_controller.connect("draw_card", _on_controller_draw_card)


## Inicia el EffectManager y conecta sus señales.
func _start_effect_manager() -> void:
	effect_manager = EffectManager.new()
	add_child(effect_manager)

	effect_manager.draw_processed.connect(_on_effect_manager_draw_processed)
	effect_manager.position = discard_pile.position


## Inicia el juego repartiendo cartas y configurando el estado inicial.
func _start_game() -> void:
	await get_tree().create_timer(0.5).timeout

	# Repartir 7 cartas a cada jugador
	for i: int in range(7):
		for player: Player in all_players:
			var card: Card = deck.draw_card()
			await player.add_card_to_hand(card)
	
	await get_tree().create_timer(0.5).timeout

	for player: Player in all_players:
		player.collapse_hand()

	await get_tree().create_timer(0.5).timeout

	var first_card: Card = deck.draw_card()
	CardManager.set_card_opacity(first_card, true)
	await discard_pile.receive_card(first_card, deck)
	#----------------------------------------------------------------------------

	effect_manager.set_arrows_opacity(1.0)

	# Marcar el juego como comenzado
	_change_state(GameState.GAME_STARTED)


## Determina y asigna el primer jugador.
func _set_first_player() -> void:
	if prev_winner:
		current_player = prev_winner
	else:
		current_player = all_players.pick_random()
	
	current_player.is_turn = true

	# Calculamos el siguiente jugador
	var current_index: int = all_players.find(current_player)
	var next_index: int = (current_index + (steps * direction) + all_players.size()) % all_players.size()
	
	next_player = all_players[next_index]

	print("Jugadores iniciales | Actual:" + current_player.name + " | Siguiente: " + next_player.name)
	print()


## Cambia el turno al siguiente jugador según la dirección y los pasos definidos.
func _change_current_player_turn() -> void:
	var total_players: int = all_players.size()
	current_player.is_turn = false 

	var prev_current_player_index: int = all_players.find(current_player)
	
	# Cálculo seguro para índices circulares
	var new_current_player_index: int = (prev_current_player_index + (steps * direction) + total_players) % total_players

	# Asignamos nuevo jugador actual
	current_player = all_players[new_current_player_index]
	current_player.is_turn = true 

	# Reiniciamos pasos a 1
	steps = 1

	# Calculamos el nuevo "siguiente" jugador
	var new_next_player_index: int = (new_current_player_index + (steps * direction) + total_players) % total_players
	next_player = all_players[new_next_player_index]

	print("-- Jugador Actual: %s --" % current_player.name)
	print("-- Jugador Siguiente: %s --" % next_player.name)


## Máquina de estados principal.
## Cambia el estado actual y ejecuta la lógica de transición.
func _change_state(new_state: GameState) -> void:
	current_state = new_state

	match current_state:
		GameState.GAME_STARTED:
			print("*** JUEGO COMENZADO ***\n")
			_set_first_player()
			print("--------------------------------------------------------------------------------")
			_change_state(GameState.APPLY_EFFECTS)
			
		GameState.APPLY_EFFECTS:
			print("### APLICANDO EFECTOS ###\n")

			effect_manager.set_game_parameters(steps, direction)
			
			if not discard_pile.top_card.is_effect_used:
				await effect_manager.process_effect(discard_pile.top_card.values["Effect"], next_player)
				discard_pile.top_card.is_effect_used = true
			
			# Obtener los parámetros actualizados del juego
			var updated_params: Dictionary = effect_manager.get_game_parameters()
			steps = updated_params["Steps"]
			direction = updated_params["Direction"]
			
			_change_state(GameState.CHANGE_TURN)
			
		GameState.CHANGE_TURN:
			print("$$$ CAMBIANDO TURNO $$$\n")
			
			for card: Card in current_player.current_hand:
				CardManager.set_card_opacity(card, false)

			_change_current_player_turn()
			if current_player.is_human:
				ai_controller.set_player(current_player)

			_change_state(GameState.PLAYING_CARDS)
			
		GameState.PLAYING_CARDS:
			print("¡¡¡ JUGADOR %s JUGANDO !!!\n" % current_player.name)
			var transition_time_seconds: float = 0.2
			
			# Habilitar interacción visual del jugador actual
			for card: Card in current_player.current_hand:
				CardManager.set_card_opacity(card, true)

			# Procesar el turno según el tipo de jugador
			if current_player.is_human:
				await ai_controller.try_to_process_turn()

			await get_tree().create_timer(transition_time_seconds).timeout

			_change_state(GameState.APPLY_EFFECTS)
			
		GameState.GAME_ENDED:
			print("||| JUEGO TERMINADO |||")


## Verifica si una carta es válida para jugar según las reglas. [br]
## Reglas: Coincidir color, coincidir símbolo, o ser carta negra (Wild).
func _is_valid_card(card_to_validate: Card) -> bool:
	var last_card: Card = discard_pile.top_card
	
	if card_to_validate.values["Color"] == "black":
		return true

	if card_to_validate.values["Color"] == last_card.values["Color"]:
		return true

	if card_to_validate.values["Symbol"] == last_card.values["Symbol"]:
		return true
	
	return false # Carta no válida


## Intenta jugar una carta para un jugador dado. [br]
## - [param target_card]: Carta que el jugador intenta jugar. [br]
## - [param target_player]: Jugador que intenta jugar la carta. [br]
func _attempt_to_play(target_card: Card, target_player: Player) -> void:
	print("El jugador %s intenta jugar una carta." % target_player.name)
	
	if not _is_valid_card(target_card):
		target_card.card_animator.play("invalid_card")
		return
	
	target_player.play_a_card(target_card)
	
	await discard_pile.receive_card(target_card, target_player)
	print("--------------------------------------------------------------------------------")


## Roba una carta hasta que se alcanza el límite. [br]
## - [param target_player]: Jugador que robará las cartas. [br]
## - [param card_count]: Cantidad máxima de cartas a robar. [br]
## - [param forced]: Si es true, robará todo. Si es false, se detiene al encontrar una válida. [br]
## - [param draw_speed]: Tiempo de espera entre robos.
func _draw_a_card(target_player: Player, card_quantity: int, forced: bool, draw_speed: float) -> void:
	for i: int in card_quantity:
		var new_card: Card = deck.draw_card()
		
		await target_player.add_card_to_hand(new_card) 
		
		for card: Card in current_player.current_hand:
			CardManager.set_card_opacity(card, true)
		
		print("Tiempo opcional de espera: ", draw_speed)
		await get_tree().create_timer(draw_speed).timeout

		if not forced:
			if _is_valid_card(new_card):
				break

	# Emitimos la señal de robo finalizado
	draw_card_finished.emit()

# --- Signal Callbacks ---
func _on_discard_pile_first_card_discarded(card: Card) -> void:
	deck.recover_card(card)


func _on_controller_play_card(card: Card, player: Player) -> void:
	_attempt_to_play(card, player)


func _on_controller_draw_card(player: Player) -> void:
	_draw_a_card(player, 1, false, 0.5)

func _on_controller_check_card(card: Card) -> void:
	if _is_valid_card(card) and current_player.is_human:
		ai_controller.add_valid_card(card)

func _on_effect_manager_draw_processed(target_player: Player, amount: int) -> void:
	var forced: bool = true
	var draw_speed: float = 0.05
	_draw_a_card(target_player, amount, forced, draw_speed)