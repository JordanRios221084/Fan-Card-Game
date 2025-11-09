# --- Script del gestor del juego ---
extends Node
class_name GameManager

signal draw_card_finished

# --- Referencis a los nodos hijos ---
@export var deck: Deck
@export var discard_pile: DiscardPile
@export var ai_controller: AIController
@export var players_container: PlayersContainer
@export var all_players: Array[Player] = []

# --- Variables para los jugadores ---
var prev_winner: Player
var current_player: Player
var next_player: Player

# --- Variables de control de turnos ---
var steps: int = 1
var direction: int = 1

# --- Variable que controla el estado actual ---
var current_state: STATES

# --- Enumerado de estados ---
enum STATES{
	IDLE,
	GAME_STARTED,
	APPLY_EFFECTS,
	CHANGE_TURN,
	PLAYING_CARDS,
	GAME_ENDED
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Cargar la base de datos de cartas
	_set_database()

	# Obtener referencias a todos los jugadores
	_get_players_references()

	# Configuramos los valores para el EffectManager
	_set_effect_values()
	
	# Conectamos las señales necesarias
	_connect_signals()

	# Comenzar el juego
	_start_game()

# --- Función para cargar la base de datos de cartas ---
func _set_database() -> void:
	deck.current_deck = CardDatabase.get_card_database().duplicate()

# --- Función para obtener referencias a nodos importantes ---
func _get_players_references() -> void:
	all_players.clear()
	for node: Node in players_container.total_current_players:
		var player: Player = node as Player
		all_players.append(player)

# --- Función para enviarle la referencia de este nodo al Effectmanager
func _set_effect_values() -> void:
	EffectManager.game_manager = self

# --- Función para conectar las señales de los nodos necesarios ---
func _connect_signals() -> void:
	ai_controller.check_card.connect(_on_ai_controller_check_card)
	ai_controller.play_card.connect(_on_ai_controller_play_card)
	ai_controller.draw_card.connect(_on_ai_controller_draw_card)

func _start_game() -> void:
	# Esperar un momento antes de repartir cartas
	await get_tree().create_timer(0.5).timeout

	# Repartir 7 cartas a cada jugador
	for i: int in range(7):
		# Para cada jugador
		for player: Player in all_players:
			var card: Card = deck.draw_card() # Tomar una carta del mazo
			await player.add_card_to_hand(card) # Añadir la carta a la mano del jugador
	
	# Esperar un momento después de repartir las cartas
	await get_tree().create_timer(0.5).timeout

	# Después de repartir, colapsar las manos de todos los jugadores
	for player: Player in all_players:
		player.colapse_hand()

	# Esperar un momento después de colapsar las manos
	await get_tree().create_timer(0.5).timeout

	# Colocar la primera carta en el montón de descarte
	await discard_pile.receive_card(deck.draw_card(), deck)

	# Marcar el juego como comenzado
	_change_state(STATES.GAME_STARTED)

# --- Función para determiniar el primer jugador de la partida ---
func _set_first_player() -> void:
	# Si hay una ganador previo, el jugador actual será igual a él
	if prev_winner:
		current_player = prev_winner
		return

	# Si el bloque anterior no se ejecuta, obtenemos el jugador actual aleatoriamente
	current_player = all_players.pick_random()
	current_player.is_turn = true

	# Configuramos el que será el siguiente jugador
	var next_player_index: int = (all_players.find(current_player) + (steps * direction)) % all_players.size()
	next_player = all_players[next_player_index]

	print("Jugadores inciales: ")
	print(current_player)
	print(next_player)
	print()

# --- Función para cambiar el turno del jugador actual ---
func _change_current_player_turn() -> void:
	# Obtenmos el total de jugadores
	var total_players: int = all_players.size()
	current_player.is_turn = false # Hacemos que el jugador actual ya no tenga el turno

	# Buscamos el indice del jugador con turno anterior
	var prev_current_player_index: int = all_players.find(current_player)
	# Encontramos el nuevo jugador actual
	var new_current_player_index: int = (prev_current_player_index + (steps * direction)) % total_players

	# Asignamos el nuevo indice al jugador actual para cambiarlo
	current_player = all_players[new_current_player_index]
	current_player.is_turn = true # Hacemos que el jugador actual tenga turno

	# Reiniciamos steps a 1
	steps = 1

	# Obtenemos el siguiente jugador con el que se calcularan los efectos de las cartas
	var new_next_player_index: int = (new_current_player_index + (steps * direction)) % total_players
	next_player = all_players[new_next_player_index] # Encontramos el siguiente jugador con el indice

	# Imprimimos para debug
	print("-- Jugador Actual:", current_player, " --")
	print("-- Jugador Siguiente: ", next_player, " --")

# --- Función que se encarga de cambiar el estado actual de la partida ---
func _change_state(new_state: STATES) -> void:
	# Actualiza la variable que almacena el estado actual
	current_state = new_state

    # Selecciona comportamiento según el estado
	match current_state:
		STATES.GAME_STARTED: # Cuando el juego comienza
			print("*** JUEGO COMENZADO ***")
			print()

            # Determina y asigna el primer jugador (o el ganador previo)
			_set_first_player()

            # Avanza inmediatamente a aplicar efectos (si los hay)
			_change_state(STATES.APPLY_EFFECTS)
			print("--------------------------------------------------------------------------------")
			
		STATES.APPLY_EFFECTS: # Aplicar efectos de la carta jugada anteriormente
			print("### APLICANDO EFECTOS DE LA CARTA JUGADA ###")
			print()

            # Si la última carta jugada no a procesado su efecto...
			if discard_pile.top_card.effect_used == false:
				# Lo procesamos y esperamos para continuar
				await EffectManager.process_effect(discard_pile.top_card.card_effect, next_player)
				discard_pile.top_card.effect_used = true
			
			_change_state(STATES.CHANGE_TURN)
			
		STATES.CHANGE_TURN: # Cambio del turno al siguiente jugador
			print("$$$ CAMBIANDO EL TURNO DEL JUGADOR ACTUAL $$$")
			print()

            # Desactivar interacción visual (opacidad) de la mano del jugador que dejó de tener el turno
			_set_opacity(current_player.current_hand, false)

            # Cambia la referencia de current_player y calcula next_player
			_change_current_player_turn()

            # Pasar al estado donde el jugador actual puede jugar
			_change_state(STATES.PLAYING_CARDS)
			
		STATES.PLAYING_CARDS: # Turno activo: el jugador juega cartas
			print("¡¡¡ JUGADOR ACTUAL JUGANDO !!!")
			print()

            # Habilitar interacción visual (opacidad) de la mano del jugador con turno
			_set_opacity(current_player.current_hand, true)

            # Si el jugador es controlado por la IA, pedirle que procese su turno (await)
			if not current_player.is_human:
				ai_controller.current_ai_player = current_player # asignar jugador al controlador IA
				await ai_controller.try_to_process_turn() # esperar a que la IA haga su acción

			# Tras jugar (o intentar), volver a aplicar efectos (si corresponde)
			await get_tree().create_timer(0.15).timeout
			_change_state(STATES.APPLY_EFFECTS)
			print("--------------------------------------------------------------------------------")
			
		STATES.GAME_ENDED: # Estado de juego terminado
			print("||| JUEGO TERMINADO |||")

# --- Función para verificar si la carta es válida ---
func _is_valid_card(card_to_validate: Card) -> bool:
	# Obtenemos la última carta jugada
	var last_card_played: Card = discard_pile.top_card

	# Si la carta tiene el mismo color que la última que se jugó
	if card_to_validate.card_color == last_card_played.card_color:
		return true # Devolver true

	# Si la carta tiene el mismo simbolo que la última que se jugó
	if card_to_validate.card_symbol == last_card_played.card_symbol:
		return true # Devolver true
	
	# Si la carta tiene color negro es un wild card
	if card_to_validate.card_color == "black":
		return true # Devolver true
	
	return false # Si ninguna regla se cumple, la carta no es válida

# --- Función para intentar jugar una carta ---
func _attempt_to_play(target_card: Card, target_player: Player) -> void:
	print("El jugador: ", target_player, ", ha intentado jugar una carta")
	# Si la carta no es válida
	if not _is_valid_card(target_card):
		target_card.card_animator.play("invalid_card") # Reproducimos la animación de carta inválida
		return
	
	# Si la carta es válida...
	target_player.play_a_card(target_card) # Jugamos la carta válida
	await discard_pile.receive_card(target_card, target_player) # Llamamos al método para descartarla

# --- Función para robar una carta hasta que se complete el total dado ---
func draw_a_new_card(target_player: Player, card_count: int, forced: bool, draw_speed: float) -> void:
	# Intentamos robar cartas la cantidad de veces que card_count nos diga
	for i: int in card_count:
		var new_card: Card = deck.draw_card() # Robamos la carta del mazo
		await target_player.add_card_to_hand(new_card) # Esperamos a que el jugador añada la carta a su mano
		_set_opacity(current_player.current_hand, true) # Hacemos la opacidad transparente
		await get_tree().create_timer(draw_speed).timeout # Añadimos tiempo adicional

		if not forced:
			# Si la carta es válida...
			if _is_valid_card(new_card):
				break # Dejamos de buscar

	# Emitimos la señal de robo finalizado
	draw_card_finished.emit()

# --- Función para cambiar la opacidad de las cartas ---
func _set_opacity(all_cards: Array, enabled: bool) -> void:
	if enabled:
		for card: Card in all_cards:
			card.opacity_sprite.modulate = Color(0, 0, 0, 0)
	else:
		for card: Card in all_cards:
			card.opacity_sprite.modulate = Color(0, 0, 0, 0.25)

# --- Función para escuchar la señal de validar cartas de la IA ----
func _on_ai_controller_check_card(target_card: Card) -> void:
	# Si la carta es válida
	if _is_valid_card(target_card):
		ai_controller.valid_cards.append(target_card) # La agregamos a valid_cards de la IA

# --- Función para escuchar la señal de jugar cartas de la IA ----
func _on_ai_controller_play_card(found_card: Card, origin_player: Player) -> void:
	# Intentamos jugar la carta
	_attempt_to_play(found_card, origin_player)

# --- Función para escuchar la señal de robar cartas de la IA ---
func _on_ai_controller_draw_card(target_player: Player,) -> void:
	draw_a_new_card(target_player, 1, false, 0.5)