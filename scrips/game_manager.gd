# --- Script del gestor del juego ---
extends Node
class_name GameManager

# --- Referencis a los nodos hijos ---
@export var deck: Deck
@export var discard_pile: DiscardPile
@export var ai_controller: AIController
@export var players_container: PlayersContainer
@export var all_players: Array[Player] = []

# --- variables para los jugadores ---
var prev_winner: Player
var current_player: Player
var next_player: Player

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
	
	_connect_signals()

	# Comenzar el juego
	_start_game()

func _connect_signals() -> void:
	ai_controller.check_card.connect(_on_ai_controller_check_card)
	ai_controller.play_card.connect(_on_ai_controller_play_card)

# --- Función para obtener referencias a nodos importantes ---
func _get_players_references() -> void:
	all_players.clear()
	for node: Node in players_container.total_current_players:
		var player: Player = node as Player
		if player:
			all_players.append(player)

# --- Función para cargar la base de datos de cartas ---
func _set_database() -> void:
	deck.current_deck = CardDatabase.get_card_database().duplicate()

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

func _change_state(new_state: STATES) -> void:
	current_state = new_state

	match current_state:
		STATES.GAME_STARTED:
			print("El juego ha comenzado!!!")
			_set_first_player()
			_change_state(STATES.APPLY_EFFECTS)
		STATES.APPLY_EFFECTS:
			print("Aplicando efectos de la carta!!!")
			_change_state(STATES.CHANGE_TURN)
		STATES.CHANGE_TURN:
			print("Cambiando el turno del jugador actual!!!")
			_change_state(STATES.PLAYING_CARDS)
		STATES.PLAYING_CARDS:
			print("El jugador actual está jugando!!!")
		STATES.GAME_ENDED:
			print("El juego a terminado!!!")

# --- Función para verificar si la carta es válida ---
func _is_valid_card(card_to_validate: Card) -> bool:
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

func _attempt_to_play(target_card: Card, target_player: Player) -> void:
	# Si la carta es válida
	if _is_valid_card(target_card):
		await discard_pile.receive_card(target_card, target_player) # Llamamos al método para descartarla
		return
	
	# Si no es válida y el jugador es humano
	if target_player.is_human:
		target_card.card_animator.play("invalid_card") # Reproducimos la animación de carta inválida
		return

# --- Función para escuchar la señal de validar cartas de la IA ----
func _on_ai_controller_check_card(target_card: Card) -> void:
	# Si la carta es válida
	if _is_valid_card(target_card):
		ai_controller.valid_cards.append(target_card) # La agregamos a valid_cards de la IA

# --- Función para escuchar la señal de jugar cartas de la IA ----
func _on_ai_controller_play_card(found_card: Card, origin_player: Player) -> void:
	# Intentamos jugar la carta
	_attempt_to_play(found_card, origin_player)
