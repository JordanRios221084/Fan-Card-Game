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
## Referencia al mazo de cartas [Deck].
@export var deck: Deck
## Referencia al montón de descarte [DiscardPile].
@export var discard_pile: DiscardPile
## Referencia al indicador de flechas.
@export var arrow_indicator: Node2D

@export_group("Player Management")
## Referencia al controlador de IA [AIController].
@export var ai_controller: AIController
## Contenedor de los jugadores [PlayersContainer].
@export var players_container: PlayersContainer
## Array que contiene referencias a todos los jugadores [Player].
@export var all_players: Array[Player] = []

# --- Public Variables ---
## Referencia al jugador que ganó la partida anterior.
var prev_winner: Player
## Referencia al jugador actual.
var current_player: Player
## Referencia al siguiente jugador.
var next_player: Player

## Cantidad de pasos a mover en el turno (1 o más).
var steps: int = 1
## Dirección del turno (1 para sentido horario, -1 para sentido antihorario).
var direction: int = 1

## Variable que almacena el estado actual del juego.
var current_state: GameState = GameState.IDLE

# --- Engine Functions ---
func _ready() -> void:
	# Cargar la base de datos de cartas
	_set_database()

	# Obtener referencias a todos los jugadores
	_get_players_references()

	# Configuramos los valores para el EffectManager (Asumimos que es Autoload)
	_set_effect_values()

	# Comenzar el juego
	_start_game()

# --- Public Functions ---
## Roba una carta hasta que se alcanza el límite. [br]
## - [param target_player]: Jugador que robará las cartas. [br]
## - [param card_count]: Cantidad máxima de cartas a robar. [br]
## - [param forced]: Si es true, robará todo. Si es false, se detiene al encontrar una válida. [br]
## - [param draw_speed]: Tiempo de espera entre robos.
func draw_a_new_card(target_player: Player, card_count: int, forced: bool, draw_speed: float) -> void:
	# Intentamos robar cartas la cantidad de veces solicitada
	for i: int in card_count:
		var new_card: Card = deck.draw_card() # Robamos la carta del mazo
		
		# Esperamos a que el jugador añada la carta a su mano
		await target_player.add_card_to_hand(new_card) 
		
		# Actualizamos visuales
		for card: Card in current_player.current_hand:
			CardManager.set_card_opacity(card, true)
		
		# Pausa dramática entre robos
		await get_tree().create_timer(draw_speed).timeout

		if not forced:
			# Si la carta es válida, dejamos de robar
			if _is_valid_card(new_card):
				break

	# Emitimos la señal de robo finalizado
	draw_card_finished.emit()

# --- Private Functions ---
## Configura el mazo de cartas con una copia de la base de datos.
func _set_database() -> void:
	# Asumimos que CardDatabase es un Autoload o clase estática
	deck.current_deck = CardDatabase.get_card_database()


## Obtiene referencias a todos los jugadores actuales y las almacena en [all_players].
func _get_players_references() -> void:
	all_players.clear()
	# Accedemos a la variable pública 'current_players' que renombramos en PlayersContainer
	for node: Node in players_container.current_players:
		if node is Player:
			all_players.append(node as Player)


## Configura el [EffectManager] con una referencia al [GameManager] actual.
func _set_effect_values() -> void:
	EffectManager.game_manager = self


## Inicia el juego repartiendo cartas y configurando el estado inicial.
func _start_game() -> void:
	await get_tree().create_timer(0.5).timeout

	# Repartir 7 cartas a cada jugador
	for i: int in range(7):
		for player: Player in all_players:
			var card: Card = deck.draw_card()
			await player.add_card_to_hand(card)
	
	await get_tree().create_timer(0.5).timeout

	# Colapsar las manos de todos los jugadores (Corregido 'colapse' -> 'collapse')
	for player: Player in all_players:
		player.collapse_hand()

	await get_tree().create_timer(0.5).timeout

	# Colocar la primera carta en el montón de descarte
	var first_card: Card = deck.draw_card()
	CardManager.set_card_opacity(first_card, true)
	await discard_pile.receive_card(first_card, deck)

	var arrows_tween: Tween = create_tween()
	arrows_tween.tween_property(arrow_indicator, "modulate:a", 0.5, 0.5)

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

	print("Jugadores iniciales | Actual: {current_player.name} | Siguiente: {next_player.name}")
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
			
			# Si la última carta jugada no ha procesado su efecto...
			if not discard_pile.top_card.effect_used:
				await EffectManager.process_effect(discard_pile.top_card.card_effect, next_player)
				discard_pile.top_card.effect_used = true
			
			_change_state(GameState.CHANGE_TURN)
			
		GameState.CHANGE_TURN:
			print("$$$ CAMBIANDO TURNO $$$\n")
			
			# Desactivar interacción visual del jugador anterior
			for card: Card in current_player.current_hand:
				CardManager.set_card_opacity(card, false)

			_change_current_player_turn()
			ai_controller.current_ai_player = current_player
			_change_state(GameState.PLAYING_CARDS)
			
		GameState.PLAYING_CARDS:
			print("¡¡¡ JUGADOR %s JUGANDO !!!\n" % current_player.name)
			
			# Habilitar interacción visual del jugador actual
			for card: Card in current_player.current_hand:
				CardManager.set_card_opacity(card, true)

			# Si es IA, procesar turno
			# if not current_player.is_human:
			await ai_controller.try_to_process_turn()

			# Nota: Si es humano, el estado se queda aquí esperando input (botones/clics)
			
			# Pequeña espera para evitar cambios bruscos
			await get_tree().create_timer(0.15).timeout

			_change_state(GameState.APPLY_EFFECTS)
			
		GameState.GAME_ENDED:
			print("||| JUEGO TERMINADO |||")


## Verifica si una carta es válida para jugar según las reglas. [br]
## Reglas: Coincidir color, coincidir símbolo, o ser carta negra (Wild).
func _is_valid_card(card_to_validate: Card) -> bool:
	var last_card: Card = discard_pile.top_card

	if card_to_validate.card_color == last_card.card_color:
		return true

	if card_to_validate.card_symbol == last_card.card_symbol:
		return true
	
	if card_to_validate.card_color == "black":
		return true
	
	return false


## Intenta jugar una carta para un jugador dado. [br]
## - [param target_card]: Carta que el jugador intenta jugar. [br]
## - [param target_player]: Jugador que intenta jugar la carta. [br]
func _attempt_to_play(target_card: Card, target_player: Player) -> void:
	print("El jugador %s intenta jugar una carta." % target_player.name)
	
	if not _is_valid_card(target_card):
		target_card.card_animator.play("invalid_card")
		return
	
	# Jugar la carta válida
	target_player.play_a_card(target_card)
	
	# Enviarla al descarte
	await discard_pile.receive_card(target_card, target_player)
	
	# Una vez jugada, debemos volver a verificar efectos
	print("--------------------------------------------------------------------------------")


# --- Signal Callbacks ---
func _on_discard_pile_first_card_discarded(card: Card) -> void:
	deck.recover_card(card)


func _on_ai_controller_play_card(card: Card, player: Player) -> void:
	_attempt_to_play(card, player)


func _on_ai_controller_draw_card(player: Player) -> void:
	draw_a_new_card(player, 1, false, 0.5)
	# Nota: Tras robar, la IA volverá a comprobar sus cartas en su propia lógica

func _on_ai_controller_check_card(card: Card) -> void:
	if _is_valid_card(card):
		ai_controller.add_valid_card(card)