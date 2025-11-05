# --- Script del gestor del juego ---
extends Node
class_name GameManager

# --- Referencis a los nodos hijos ---
var all_players: Array = []
var deck: Deck
var discard_pile: DiscardPile
var ai_controller: AIController

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
	# Obtener referencias a nodos importantes
	get_references()

	# Cargar la base de datos de cartas
	set_database()
	
	# Comenzar el juego
	start_game()

# --- Función para obtener referencias a nodos importantes ---
func get_references() -> void:
	for node: Node in self.get_children():
		if node is Deck:
			deck = node as Deck
		
		if node is Player:
			all_players.append(node as Player )

		if node is DiscardPile:
			discard_pile = node as DiscardPile
		
		if node is AIController:
			ai_controller = node as AIController

# --- Función para cargar la base de datos de cartas ---
func set_database() -> void:
	deck.current_deck = CardDatabase.get_card_database().duplicate()

func start_game() -> void:
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
	change_state(STATES.GAME_STARTED)

# --- Función para determiniar el primer jugador de la partida ---
func set_first_player() -> void:
	# Si hay una ganador previo, el jugador actual será igual a él
	if prev_winner:
		current_player = prev_winner
		return

	# Si el bloque anterior no se ejecuta, obtenemos el jugador actual aleatoriamente
	current_player = all_players.pick_random()

func change_state(new_state: STATES) -> void:
	current_state = new_state

	match current_state:
		STATES.GAME_STARTED:
			print("El juego ha comenzado!!!")
			set_first_player()
			change_state(STATES.APPLY_EFFECTS)
		STATES.APPLY_EFFECTS:
			print("Aplicando efectos de la carta!!!")
			change_state(STATES.CHANGE_TURN)
		STATES.CHANGE_TURN:
			print("Cambiando el turno del jugador actual!!!")
			change_state(STATES.PLAYING_CARDS)
		STATES.PLAYING_CARDS:
			print("El jugador actual está jugando!!!")
		STATES.GAME_ENDED:
			print("El juego a terminado!!!")

# --- Función para verificar si la carta es válida ---
func is_valid_card(card_to_validate: Card) -> bool:
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

# --- Función para poder validar las cartas por parte de la IA ----
func _on_ai_controller_check_card(target_card: Card) -> void:
	# Si la carta es válida
	if is_valid_card(target_card):
		ai_controller.valid_cards.append(target_card) # La agregamos a valid_cards de la IA

