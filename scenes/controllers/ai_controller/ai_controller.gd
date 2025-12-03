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
signal play_card(card: Card, layer: Player)
## Solicita que el jugador IA robe una carta.
signal draw_card(player: Player)

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


## Añade una carta válida a la lista de cartas válidas.
## [param card] La carta que se considera válida para jugar.
func add_valid_card(card: Card) -> void:
	# Añade una carta válida a la lista de cartas válidas.
	_valid_cards.append(card)


# --- Private Functions ---
## Procesa el turno del jugador IA actual.
## Simula el pensamiento de la IA, verifica las cartas válidas y decide si jugar o robar.
func _process_turn() -> void:
	print("-- Jugador IA actual: ", current_ai_player, " --")
	print()
	
	# Variable local para el tiempo de espera (no necesita ser de clase)
	var wait_time: float = randf_range(0.5, 1.0)

	# Multiplicador para variar el tiempo de espera inicial
	await get_tree().create_timer(wait_time * 1.2).timeout

	# Verificamos cartas (Añadido 'await' para asegurar sincronía)
	await _check_current_cards(false)

	# Divisor para variar el tiempo de espera intermedio
	await get_tree().create_timer(wait_time / 0.8).timeout
	
	# Lógica de decisión: Robar o Jugar
	if _valid_cards.is_empty():
		draw_card.emit(current_ai_player)
		# Verificamos de nuevo tras robar (esperando a que termine el robo)
		await _check_current_cards(true)
	
	if not _valid_cards.is_empty():
		var ai_found_card: Card = _valid_cards.pick_random()
		play_card.emit(ai_found_card, current_ai_player)

	_clear_variables()


## Verifica las cartas actuales en la mano del jugador IA.
## Si [param try_draw] es verdadero, espera a que el jugador termine de robar antes de verificar.
func _check_current_cards(try_draw: bool) -> void:
	# Intentamos robar una carta si es necesario
	if try_draw:
		await game_manager.draw_card_finished

	# Reiniciamos las cartas válidas antes de comprobar
	_valid_cards.clear()

	# Emitimos señal para cada carta en la mano
	if current_ai_player and current_ai_player.current_hand:
		for card: Card in current_ai_player.current_hand:
			check_card.emit(card)
	
	# Pequeña espera para dar tiempo a procesar las señales o simular "lectura"
	await get_tree().create_timer(0.5).timeout


## Limpia las variables del controlador de la IA.
## Reinicia el jugador actual y la lista de cartas para el siguiente turno.
func _clear_variables() -> void:
	current_ai_player = null
	_valid_cards.clear()